import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_bottom_button.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_screen_body.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_state.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_shimmer.dart';
import 'package:pythagoras/core/utils/url_launcher_util.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';

import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_landscape.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/apple_iap_purchase_section.dart';
import 'package:pythagoras/features/courses/presentation/utils/apple_iap_success_message.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  final bool isEnrolled;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.isEnrolled,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with WidgetsBindingObserver {
  late final CourseDetailsCubit _courseDetailsCubit;
  late final RequestEnrollmentCubit _requestEnrollmentCubit;
  late final RemoteConfigCubit _remoteConfigCubit;
  late final AppleIapCubit _appleIapCubit;
  bool _isWaitingForWhatsApp = false;
  int? _expandedRestoreChapterId;

  void _onChapterExpansionChanged(int chapterId, bool isExpanded) {
    if (Theme.of(context).platform != TargetPlatform.iOS) return;
    setState(() {
      _expandedRestoreChapterId = isExpanded
          ? chapterId
          : (_expandedRestoreChapterId == chapterId
                ? null
                : _expandedRestoreChapterId);
    });
  }

  int? _restoreChapterFor(CourseDetail course) {
    if (course.isEnrolled || _expandedRestoreChapterId == null) return null;
    for (final chapter in course.chapters) {
      if (chapter.id == _expandedRestoreChapterId &&
          !chapter.isEnrolled &&
          chapter.requestStatus.trim().toLowerCase() != 'accepted') {
        return chapter.id;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _courseDetailsCubit = sl<CourseDetailsCubit>()
      ..fetchCourseDetails(widget.courseId);
    _requestEnrollmentCubit = sl<RequestEnrollmentCubit>();
    _remoteConfigCubit = sl<RemoteConfigCubit>()..load();
    _appleIapCubit = sl<AppleIapCubit>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _courseDetailsCubit.close();
    _requestEnrollmentCubit.close();
    _remoteConfigCubit.close();
    _appleIapCubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isWaitingForWhatsApp) {
      _isWaitingForWhatsApp = false;
      _courseDetailsCubit.fetchCourseDetails(widget.courseId);
      if (mounted) {
        context.read<CoursesListCubit>().fetchCourses();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _courseDetailsCubit),
        BlocProvider.value(value: _requestEnrollmentCubit),
        BlocProvider.value(value: _remoteConfigCubit),
        BlocProvider.value(value: _appleIapCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<CourseDetailsCubit, CourseDetailsState>(
            listener: (context, state) {
              if (state is! CourseDetailsLoaded) return;
              final requestStatus = state.courseDetail.requestStatus
                  ?.trim()
                  .toLowerCase();
              final eligibleChapterIds = state.courseDetail.chapters
                  .where(
                    (chapter) =>
                        !state.courseDetail.isEnrolled &&
                        !chapter.isEnrolled &&
                        chapter.requestStatus.trim().toLowerCase() ==
                            'not_requested',
                  )
                  .map((chapter) => chapter.id)
                  .toSet();
              _appleIapCubit.updateCourseAndChapterAccess(
                courseId: state.courseDetail.id,
                isRequestStatusEligible: requestStatus == 'not_requested',
                isEnrolled: state.courseDetail.isEnrolled,
                hasPendingRequest: requestStatus == 'pending',
                eligibleChapterIds: eligibleChapterIds,
                courseAppleProductId: state.courseDetail.appleProductId,
                chapterAppleProductIds: {
                  for (final chapter in state.courseDetail.chapters)
                    chapter.id: chapter.appleProductId,
                },
              );
            },
          ),
          // ── Android: WhatsApp redirect flow (unchanged) ──────────────────
          BlocListener<RequestEnrollmentCubit, RequestEnrollmentState>(
            listener: (context, state) async {
              if (state is RequestEnrollmentLoading) {
                EasyLoading.show(status: 'جاري التحميل...');
              } else if (state is RequestEnrollmentSuccess) {
                EasyLoading.dismiss();
                final launched = await UrlLauncherUtil.openWhatsAppUrl(
                  state.whatsappUrl,
                  chapterTitle: state.chapterTitle,
                  courseTitle: state.courseTitle,
                  isChapter: state.isChapter,
                );
                if (launched) {
                  _isWaitingForWhatsApp = true;
                } else {
                  EasyLoading.showError(
                    'تعذر فتح الواتساب، يرجى التأكد من تثبيت التطبيق',
                  );
                }
              } else if (state is RequestEnrollmentError) {
                EasyLoading.dismiss();
                EasyLoading.showError(state.message);
              }
            },
          ),
          BlocListener<AppleIapCubit, AppleIapState>(
            listener: (context, state) {
              if (state.status == AppleIapStatus.loading &&
                  state.message == 'جاري استعادة المشتريات...') {
                EasyLoading.show(status: state.message);
              } else if (state.status == AppleIapStatus.purchasing) {
                EasyLoading.show(status: 'جاري بدء عملية الشراء عبر Apple...');
              } else if (state.status == AppleIapStatus.pending) {
                EasyLoading.show(status: 'جاري انتظار تأكيد Apple...');
              } else if (state.status == AppleIapStatus.verifying) {
                EasyLoading.show(status: 'جارٍ التحقق من عملية الشراء...');
              } else if (state.status == AppleIapStatus.restored ||
                  state.status == AppleIapStatus.purchaseConfirmed) {
                EasyLoading.dismiss();
                final restoredTarget = _appleIapCubit.targetFor(
                  state.activeProductId ?? '',
                );
                final targetMatchesCurrentCourse =
                    restoredTarget != null &&
                    (restoredTarget.type == AppleIapProductType.course
                        ? restoredTarget.contentId == widget.courseId
                        : restoredTarget.parentContentId == widget.courseId);
                if (targetMatchesCurrentCourse) {
                  _courseDetailsCubit.fetchCourseDetails(widget.courseId);
                  if (mounted) {
                    context.read<CoursesListCubit>().fetchCourses();
                  }
                }
                EasyLoading.showSuccess(
                  appleIapSuccessMessage(
                    isRestore: state.status == AppleIapStatus.restored,
                    alreadyEnrolled: state.alreadyEnrolled,
                    productType: restoredTarget?.type,
                  ),
                );
              } else if (state.status == AppleIapStatus.restoreEmpty) {
                EasyLoading.dismiss();
                EasyLoading.showInfo(
                  state.message ?? 'لم يتم العثور على مشتريات سابقة',
                );
              } else if (state.status == AppleIapStatus.cancelled) {
                EasyLoading.dismiss();
                EasyLoading.showInfo(state.message ?? 'تم إلغاء عملية الشراء');
              } else if (state.status == AppleIapStatus.failure) {
                EasyLoading.dismiss();
                EasyLoading.showError(
                  state.message ?? 'تعذر إتمام عملية Apple',
                );
              } else if (state.status == AppleIapStatus.transactionConflict) {
                EasyLoading.dismiss();
                EasyLoading.showError(
                  state.message ?? 'هذه المعاملة مرتبطة بحساب طالب آخر',
                );
              } else if (state.status == AppleIapStatus.purchaseTimedOut) {
                EasyLoading.dismiss();
                EasyLoading.showInfo(
                  state.message ?? 'لم يصل تأكيد من Apple؛ استخدم Restore.',
                );
              } else if (state.status == AppleIapStatus.verificationRequired) {
                EasyLoading.dismiss();
                EasyLoading.showError(
                  state.message ?? 'لم يتم تأكيد استحقاق المحتوى من الخادم.',
                  duration: const Duration(seconds: 6),
                );
              }
            },
          ),
          BlocListener<RemoteConfigCubit, RemoteConfigState>(
            listenWhen: (previous, current) =>
                previous.iosIapEnabled != current.iosIapEnabled,
            listener: (context, state) {
              _appleIapCubit.updateIapEnabled(state.iosIapEnabled);
            },
          ),
        ],

        child: BlocBuilder<RemoteConfigCubit, RemoteConfigState>(
          builder: (context, remoteConfigState) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isTabletLandscape =
                    constraints.maxWidth >= 900 &&
                    constraints.maxHeight >= 600 &&
                    constraints.maxWidth > constraints.maxHeight;

                return Scaffold(
                  backgroundColor: isTabletLandscape
                      ? const Color(0xFFF8F9FA)
                      : Colors.white,
                  appBar: isTabletLandscape ? null : const CourseDetailAppBar(),
                  body: BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
                    builder: (context, state) {
                      if (state is CourseDetailsLoading) {
                        if (isTabletLandscape) {
                          return CourseDetailTabletShimmer(
                            constraints: constraints,
                          );
                        }
                        return const CourseDetailShimmer();
                      } else if (state is CourseDetailsError) {
                        return NoInternetWidget(
                          message: state.message,
                          onRetry: () => _courseDetailsCubit.fetchCourseDetails(
                            widget.courseId,
                          ),
                        );
                      } else if (state is CourseDetailsLoaded) {
                        final updatedCourse = state.courseDetail;
                        final restoreChapterId = _restoreChapterFor(
                          updatedCourse,
                        );

                        // ── Tablet Landscape: dedicated two-column layout ──
                        if (isTabletLandscape) {
                          return CourseDetailTabletLandscape(
                            course: updatedCourse,
                            constraints: constraints,
                            restoreChapterId: restoreChapterId,
                            onChapterExpansionChanged:
                                _onChapterExpansionChanged,
                          );
                        }

                        // ── Mobile Portrait & Tablet Portrait: original layout untouched ──
                        return Column(
                          children: [
                            CourseDetailBodyRegion(
                              child: SafeArea(
                                top: false,
                                bottom:
                                    Theme.of(context).platform !=
                                    TargetPlatform.iOS,
                                child: CourseDetailScreenBody(
                                  course: updatedCourse,
                                  restoreChapterId: restoreChapterId,
                                  onChapterExpansionChanged:
                                      _onChapterExpansionChanged,
                                ),
                              ),
                            ),
                            AppleIapPurchaseSection(
                              type: AppleIapProductType.course,
                              contentId: updatedCourse.id,
                              appleProductId: updatedCourse.appleProductId,
                              isRequestStatusEligible:
                                  updatedCourse.requestStatus
                                      ?.trim()
                                      .toLowerCase() ==
                                  'not_requested',
                              isEnrolled: updatedCourse.isEnrolled,
                              hasPendingRequest:
                                  updatedCourse.requestStatus
                                      ?.trim()
                                      .toLowerCase() ==
                                  'pending',
                              showRestoreButton:
                                  restoreChapterId == null &&
                                  (remoteConfigState
                                          .courseLessonRequestsEnabled ||
                                      updatedCourse.isEnrolled),
                            ),
                            BlocBuilder<AppleIapCubit, AppleIapState>(
                              builder: (context, appleIapState) {
                                final requestStatus = updatedCourse
                                    .requestStatus
                                    ?.trim()
                                    .toLowerCase();
                                final productId = updatedCourse.appleProductId
                                    ?.trim();
                                final hasVisibleAppleActions =
                                    Theme.of(context).platform ==
                                        TargetPlatform.iOS &&
                                    remoteConfigState.iosIapEnabled &&
                                    requestStatus == 'not_requested' &&
                                    !updatedCourse.isEnrolled &&
                                    productId != null &&
                                    productId.isNotEmpty &&
                                    appleIapState.products.any(
                                      (product) => product.id == productId,
                                    );
                                return CourseDetailBottomButton(
                                  course: updatedCourse,
                                  appleIapActionsVisible:
                                      hasVisibleAppleActions,
                                  showRestoreButton: restoreChapterId == null,
                                );
                              },
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

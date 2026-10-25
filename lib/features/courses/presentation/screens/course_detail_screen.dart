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
import 'package:pythagoras/features/courses/presentation/cubit/direct_request/direct_request_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/direct_request/direct_request_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_state.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_shimmer.dart';
import 'package:pythagoras/core/utils/url_launcher_util.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';

import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_landscape.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/apple_iap_purchase_section.dart';

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
  late final DirectRequestCubit _directRequestCubit;
  late final RemoteConfigCubit _remoteConfigCubit;
  late final AppleIapCubit _appleIapCubit;
  bool _isWaitingForWhatsApp = false;
  String? _pendingApplePurchaseKey;

  @override
  void initState() {
    super.initState();
    _courseDetailsCubit = sl<CourseDetailsCubit>()
      ..fetchCourseDetails(widget.courseId);
    _requestEnrollmentCubit = sl<RequestEnrollmentCubit>();
    _directRequestCubit = sl<DirectRequestCubit>();
    _remoteConfigCubit = sl<RemoteConfigCubit>()..load();
    _appleIapCubit = sl<AppleIapCubit>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _courseDetailsCubit.close();
    _requestEnrollmentCubit.close();
    _directRequestCubit.close();
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
        BlocProvider.value(value: _directRequestCubit),
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
              _appleIapCubit.updateCourseAccess(
                isRequestStatusEligible: requestStatus == 'not_requested',
                isEnrolled: state.courseDetail.isEnrolled,
                hasPendingRequest: requestStatus == 'pending',
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
          // ── iOS: direct enrollment flow ──────────────────────────────────
          BlocListener<DirectRequestCubit, DirectRequestState>(
            listener: (context, state) async {
              if (state is DirectRequestLoading) {
                EasyLoading.show(status: 'جاري التحميل...');
              } else if (state is DirectRequestSuccess) {
                EasyLoading.dismiss();
                EasyLoading.showSuccess(state.message);
                final purchaseKey = _pendingApplePurchaseKey;
                if (purchaseKey != null) {
                  _pendingApplePurchaseKey = null;
                  await _appleIapCubit.completeConfirmedPurchase(purchaseKey);
                }
                if (!context.mounted) return;
                // Refresh course details and courses list immediately after
                // a successful iOS direct request — mirrors the same two
                // calls Android makes when the app returns from WhatsApp
                // (see didChangeAppLifecycleState).
                _courseDetailsCubit.fetchCourseDetails(widget.courseId);
                if (mounted) {
                  context.read<CoursesListCubit>().fetchCourses();
                }
              } else if (state is DirectRequestError) {
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
              } else if (state.status == AppleIapStatus.purchaseConfirmed) {
                EasyLoading.dismiss();
              } else if (state.status == AppleIapStatus.restored) {
                EasyLoading.dismiss();
                EasyLoading.showInfo(
                  'تمت استعادة معاملة Apple. هذا لا يعني تفعيل الكورس؛ يعتمد التفعيل على حالة الحساب من الخادم.',
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
                EasyLoading.showInfo(
                  'المعاملة مستلمة، لكن تعذر التحقق من تفعيل الكورس.',
                );
              }

              if (state.status != AppleIapStatus.purchaseConfirmed ||
                  state.transactionKey == null ||
                  _pendingApplePurchaseKey != null) {
                return;
              }

              final target = AppleIapProductCatalog.targetFor(
                state.activeProductId ?? '',
              );
              if (target?.type != AppleIapProductType.course ||
                  target?.contentId != widget.courseId) {
                return;
              }

              _pendingApplePurchaseKey = state.transactionKey;
              _directRequestCubit.requestCourse(widget.courseId);
            },
          ),
          BlocListener<RemoteConfigCubit, RemoteConfigState>(
            listenWhen: (previous, current) =>
                previous.iosIapEnabled != current.iosIapEnabled,
            listener: (context, state) {
              _appleIapCubit.updateIapEnabled(
                state.iosIapEnabled &&
                    AppleIapProductCatalog.hasProductFor(
                      AppleIapProductType.course,
                      widget.courseId,
                    ),
              );
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

                        // ── Tablet Landscape: dedicated two-column layout ──
                        if (isTabletLandscape) {
                          return CourseDetailTabletLandscape(
                            course: updatedCourse,
                            constraints: constraints,
                          );
                        }

                        // ── Mobile Portrait & Tablet Portrait: original layout untouched ──
                        return Column(
                          children: [
                            CourseDetailBodyRegion(
                              child: SafeArea(
                                top: false,
                                child: CourseDetailScreenBody(
                                  course: updatedCourse,
                                ),
                              ),
                            ),
                            AppleIapPurchaseSection(
                              type: AppleIapProductType.course,
                              contentId: updatedCourse.id,
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
                            ),
                            BlocBuilder<AppleIapCubit, AppleIapState>(
                              builder: (context, appleIapState) {
                                final requestStatus = updatedCourse
                                    .requestStatus
                                    ?.trim()
                                    .toLowerCase();
                                final productIds = AppleIapProductCatalog
                                    .products
                                    .entries
                                    .where(
                                      (entry) =>
                                          entry.value.type ==
                                              AppleIapProductType.course &&
                                          entry.value.contentId ==
                                              updatedCourse.id,
                                    )
                                    .map((entry) => entry.key)
                                    .toSet();
                                final hasVisibleAppleActions =
                                    Theme.of(context).platform ==
                                        TargetPlatform.iOS &&
                                    remoteConfigState.iosIapEnabled &&
                                    requestStatus == 'not_requested' &&
                                    !updatedCourse.isEnrolled &&
                                    appleIapState.products.any(
                                      (product) =>
                                          productIds.contains(product.id),
                                    );
                                return CourseDetailBottomButton(
                                  course: updatedCourse,
                                  appleIapActionsVisible:
                                      hasVisibleAppleActions,
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

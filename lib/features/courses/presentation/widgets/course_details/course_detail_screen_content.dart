import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/core/utils/url_launcher_util.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_state.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';
import 'package:pythagoras/features/courses/presentation/utils/apple_iap_success_message.dart';
import 'package:pythagoras/features/courses/presentation/widgets/apple_iap_purchase_section.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_bottom_button.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_screen_body.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_landscape.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_shimmer.dart';

class CourseDetailScreenContent extends StatelessWidget {
  const CourseDetailScreenContent({
    super.key,
    required this.courseId,
    required this.courseDetailsCubit,
    required this.requestEnrollmentCubit,
    required this.remoteConfigCubit,
    required this.appleIapCubit,
    required this.onWhatsAppLaunched,
  });

  final int courseId;
  final CourseDetailsCubit courseDetailsCubit;
  final RequestEnrollmentCubit requestEnrollmentCubit;
  final RemoteConfigCubit remoteConfigCubit;
  final AppleIapCubit appleIapCubit;
  final ValueChanged<bool> onWhatsAppLaunched;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: courseDetailsCubit),
        BlocProvider.value(value: requestEnrollmentCubit),
        BlocProvider.value(value: remoteConfigCubit),
        BlocProvider.value(value: appleIapCubit),
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
              appleIapCubit.updateCourseAndChapterAccess(
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
          BlocListener<RequestEnrollmentCubit, RequestEnrollmentState>(
            listener: (context, state) async {
              if (state is RequestEnrollmentLoading) {
                EasyLoading.show(status: 'جاري التحميل...');
              } else if (state is RequestEnrollmentSuccess) {
                EasyLoading.dismiss();
                if (Theme.of(context).platform == TargetPlatform.iOS) {
                  courseDetailsCubit.fetchCourseDetails(courseId);
                  context.read<CoursesListCubit>().fetchCourses();
                }
                final launched = await UrlLauncherUtil.openWhatsAppUrl(
                  state.whatsappUrl,
                  chapterTitle: state.chapterTitle,
                  courseTitle: state.courseTitle,
                  isChapter: state.isChapter,
                );
                if (launched) {
                  onWhatsAppLaunched(true);
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
              if (state.restoreInProgress) {
                if (state.status == AppleIapStatus.loading) {
                  EasyLoading.show(status: state.message);
                } else if (state.status == AppleIapStatus.pending) {
                  EasyLoading.show(status: 'جاري انتظار تأكيد Apple...');
                } else if (state.status == AppleIapStatus.verifying) {
                  EasyLoading.show(status: 'جارٍ التحقق من عملية الشراء...');
                }
                return;
              }

              if (state.status == AppleIapStatus.verificationRequired &&
                  state.restoreHasUnmappedProducts) {
                final currentDetailsState = courseDetailsCubit.state;
                final courseAlreadyAvailable =
                    currentDetailsState is CourseDetailsLoaded &&
                    currentDetailsState.courseDetail.isEnrolled;
                if (state.restoreHasConfirmedEnrollment ||
                    courseAlreadyAvailable) {
                  EasyLoading.dismiss();
                  EasyLoading.showInfo(
                    courseAlreadyAvailable
                        ? 'الدورة متاحة بالفعل. لم يتم تفعيل مشتريات أخرى غير مرتبطة بها.'
                        : 'تم تأكيد المحتوى المرتبط بالدورة الحالية. لم يتم تفعيل مشتريات أخرى غير مرتبطة بها.',
                  );
                  return;
                }
              }

              final shouldRefreshCourse =
                  state.status == AppleIapStatus.restored ||
                  state.status == AppleIapStatus.purchaseConfirmed ||
                  (state.restoreHasConfirmedEnrollment &&
                      (state.status == AppleIapStatus.failure ||
                          state.status == AppleIapStatus.verificationRequired ||
                          state.status == AppleIapStatus.transactionConflict));
              if (shouldRefreshCourse) {
                final target = appleIapCubit.targetFor(
                  state.activeProductId ?? '',
                );
                final targetMatchesCurrentCourse =
                    target != null &&
                    (target.type == AppleIapProductType.course
                        ? target.contentId == courseId
                        : target.parentContentId == courseId);
                if (targetMatchesCurrentCourse) {
                  courseDetailsCubit.fetchCourseDetails(courseId);
                  if (context.mounted) {
                    context.read<CoursesListCubit>().fetchCourses();
                  }
                }
              }

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
                final restoredTarget = appleIapCubit.targetFor(
                  state.activeProductId ?? '',
                );
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
              appleIapCubit.updateIapEnabled(state.iosIapEnabled);
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

                return BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
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
                        onRetry: () =>
                            courseDetailsCubit.fetchCourseDetails(courseId),
                      );
                    } else if (state is CourseDetailsLoaded) {
                      final updatedCourse = state.courseDetail;

                      if (isTabletLandscape) {
                        return CourseDetailTabletLandscape(
                          course: updatedCourse,
                          constraints: constraints,
                        );
                      }

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
                                remoteConfigState.courseLessonRequestsEnabled ||
                                updatedCourse.isEnrolled,
                          ),
                          BlocBuilder<AppleIapCubit, AppleIapState>(
                            builder: (context, appleIapState) {
                              final requestStatus = updatedCourse.requestStatus
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
                                appleIapActionsVisible: hasVisibleAppleActions,
                              );
                            },
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/auth/presentation/widgets/auth_bottom_sheet.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_cubit.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/cubit/direct_request/direct_request_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/apple_iap_action_spacing.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';
import 'package:pythagoras/features/courses/presentation/widgets/apple_iap_purchase_section.dart';

class CourseDetailBottomButton extends StatelessWidget {
  final CourseDetail course;
  final bool appleIapActionsVisible;
  final bool showRestoreButton;

  const CourseDetailBottomButton({
    super.key,
    required this.course,
    this.appleIapActionsVisible = false,
    this.showRestoreButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final requestsEnabled = context
        .watch<RemoteConfigCubit>()
        .state
        .courseLessonRequestsEnabled;
    if (!course.isEnrolled && !requestsEnabled) {
      if (Theme.of(context).platform == TargetPlatform.iOS &&
          showRestoreButton) {
        return SafeArea(
          top: false,
          child: AppleIapPurchaseSection(
            key: const ValueKey('course-detail-restore-action-slot'),
            type: AppleIapProductType.course,
            contentId: course.id,
            appleProductId: course.appleProductId,
            isRequestStatusEligible:
                course.requestStatus?.trim().toLowerCase() == 'not_requested',
            hasPendingRequest:
                course.requestStatus?.trim().toLowerCase() == 'pending',
            showPurchaseButton: false,
            showRestoreButton: true,
          ),
        );
      }
      return const SizedBox.shrink();
    }
    final isPending = course.requestStatus?.trim().toLowerCase() == 'pending';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        appleIapActionsVisible ? appleIapActionSpacing.h : 16.h,
        20.w,
        24.h,
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          text: course.isEnrolled
              ? 'عرض الدورة'
              : isPending
              ? 'قيد الانتظار'
              : 'طلب الدورة',

          onPressed: isPending
              ? null
              : () async {
                  if (course.isEnrolled) {
                    context.push(Routes.courseSectionsScreen, extra: course);
                    return;
                  }

                  final prefs = sl<PreferencesStorage>();
                  final token = prefs.getUserToken();
                  if (token == null || token.isEmpty) {
                    // Guest trying to purchase, show login sheet
                    final didLogin = await AuthBottomSheet.show(context);
                    if (didLogin == true && context.mounted) {
                      // Refresh global and local data without auto-purchasing
                      context.read<ProfileCubit>().getAccountInfo();
                      context.read<CoursesListCubit>().fetchCourses();
                      context.read<CourseDetailsCubit>().fetchCourseDetails(
                        course.id,
                      );
                    }
                    return;
                  }

                  // ── iOS: direct enrollment (no WhatsApp redirect) ──
                  if (Theme.of(context).platform == TargetPlatform.iOS) {
                    context.read<DirectRequestCubit>().requestCourse(course.id);
                  } else {
                    // ── Android: WhatsApp redirect flow ──
                    context.read<RequestEnrollmentCubit>().requestCourse(
                      course.id,
                      courseTitle: course.title,
                    );
                  }
                },
          radius: 14.r,
          height: 52.h,
          textSize: 16.sp,
        ),
      ),
    );
  }
}

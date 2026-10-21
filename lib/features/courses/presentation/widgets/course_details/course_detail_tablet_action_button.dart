import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/features/auth/presentation/widgets/auth_bottom_sheet.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/direct_request/direct_request_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';

/// Fixed action button ("طلب الدورة" / "عرض الدورة") for Tablet Landscape.
/// Stays sticky on the screen aligned with the curriculum column.
class CourseDetailTabletActionButton extends StatelessWidget {
  final CourseDetail course;

  const CourseDetailTabletActionButton({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isPending = course.requestStatus?.trim().toLowerCase() == 'pending';

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppLightColors.primary.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
                    final didLogin = await AuthBottomSheet.show(context);
                    if (didLogin == true && context.mounted) {
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
          radius: 14,
          height: 52,
          textSize: 16,
          textWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

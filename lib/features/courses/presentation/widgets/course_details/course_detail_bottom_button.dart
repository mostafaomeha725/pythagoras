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

class CourseDetailBottomButton extends StatelessWidget {
  final CourseDetail course;

  const CourseDetailBottomButton({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
        child: AppButton(
          text: course.isEnrolled ? 'عرض الدورة' : 'طلب الدورة',
          onPressed: () async {
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
                context.read<CourseDetailsCubit>().fetchCourseDetails(course.id);
              }
              return;
            }

            context.read<RequestEnrollmentCubit>().requestCourse(
              course.id,
              courseTitle: course.title,
            );
          },
          radius: 14.r,
          height: 52.h,
          textSize: 16.sp,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          text: course.isEnrolled ? 'عرض الدورة' : 'شراء الدورة',
          onPressed: () {
            if (course.isEnrolled) {
              context.push(Routes.courseSectionsScreen, extra: course);
            } else {
              context.read<RequestEnrollmentCubit>().requestCourse(course.id);
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

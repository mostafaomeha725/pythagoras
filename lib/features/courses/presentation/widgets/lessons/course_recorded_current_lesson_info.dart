import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';

class CourseRecordedCurrentLessonInfo extends StatelessWidget {
  final CourseLesson? selectedLesson;
  final CourseDetail course;

  const CourseRecordedCurrentLessonInfo({
    super.key,
    required this.selectedLesson,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EEF5),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: AppText(
                'الدرس الحالي •',
                style: font12w700.copyWith(color: AppLightColors.primary),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        AppText(
          selectedLesson?.title ?? 'اختر درساً للبدء',
          style: font22w700.copyWith(color: const Color(0xFF1E1E2D)),
          maxLines: 2,
        ),
        SizedBox(height: 12.h),
        AppText(
          selectedLesson?.description ?? course.description ?? '',
          style: font14w400.copyWith(
            color: const Color(0xFF6B7280),
            height: 1.6,
          ),
          maxLines: 4,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: AppText(
                course.title,
                style: font12w500.copyWith(color: const Color(0xFF6B7280)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Container(
                width: 4.w,
                height: 4.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1D5DB),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: AppText(
                course.instructor?.name ?? '',
                style: font12w500.copyWith(color: const Color(0xFF6B7280)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

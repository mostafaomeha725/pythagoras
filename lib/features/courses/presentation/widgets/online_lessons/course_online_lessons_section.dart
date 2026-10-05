import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/online_lesson.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/online_lesson_card.dart';

class CourseOnlineLessonsSection extends StatelessWidget {
  final String title;
  final List<OnlineLesson> lessons;
  final IconData emptyIcon;
  final String emptyMessage;

  const CourseOnlineLessonsSection({
    super.key,
    required this.title,
    required this.lessons,
    required this.emptyIcon,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              title,
              style: font18w700.copyWith(
                color: const Color(0xFF1E1E2D),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EEF5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: AppText(
                '${lessons.length} حصص',
                style: font10w700.copyWith(
                  color: AppLightColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (lessons.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Column(
                children: [
                  Icon(
                    emptyIcon,
                    size: 64.sp,
                    color: const Color(0xFFD1D5DB),
                  ),
                  SizedBox(height: 16.h),
                  AppText(
                    emptyMessage,
                    style: font16w700.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                    alignment: AlignmentDirectional.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...lessons.map(
            (lesson) => OnlineLessonCard(lesson: lesson),
          ),
      ],
    );
  }
}

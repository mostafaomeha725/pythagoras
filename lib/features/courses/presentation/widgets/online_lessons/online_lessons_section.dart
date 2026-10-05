import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/online_lesson.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/online_lesson_card.dart';

/// A titled section (e.g. "مباشر الآن" or "الحصص القادمة") with a lesson list.
class OnlineLessonsSection extends StatelessWidget {
  final String title;
  final String pillText;
  final List<OnlineLesson> lessons;

  const OnlineLessonsSection({
    super.key,
    required this.title,
    required this.pillText,
    required this.lessons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(title, style: font18w700.copyWith(color: const Color(0xFF1E1E2D))),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EEF5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: AppText(pillText, style: font10w700.copyWith(color: AppLightColors.primary)),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...lessons.map((lesson) => OnlineLessonCard(lesson: lesson)),
      ],
    );
  }
}

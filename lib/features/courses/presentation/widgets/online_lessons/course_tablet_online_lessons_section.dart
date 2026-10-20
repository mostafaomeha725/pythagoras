import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/online_lesson.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/course_tablet_online_lesson_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/course_tasks_two_column_grid.dart';

/// Section component for Online Lessons on Tablet Landscape.
/// Displays a header and a 2-column grid of lesson cards or an empty state.
class CourseTabletOnlineLessonsSection extends StatelessWidget {
  final String title;
  final List<OnlineLesson> lessons;
  final IconData emptyIcon;
  final String emptyMessage;

  const CourseTabletOnlineLessonsSection({
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
        // Section Header: Title + Count Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              title,
              style: font18w700.copyWith(
                color: const Color(0xFF1E1E2D),
                fontSize: 18,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF4FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: AppText(
                '${lessons.length} حصص',
                style: font12w700.copyWith(
                  color: AppLightColors.primary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2-Column Grid or Empty State
        if (lessons.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  emptyIcon,
                  size: 44,
                  color: const Color(0xFFD1D5DB),
                ),
                const SizedBox(height: 12),
                AppText(
                  emptyMessage,
                  style: font16w700.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                  alignment: AlignmentDirectional.center,
                ),
              ],
            ),
          )
        else
          CourseTasksTwoColumnGrid(
            children: lessons
                .map((lesson) => CourseTabletOnlineLessonCard(lesson: lesson))
                .toList(),
          ),
      ],
    );
  }
}

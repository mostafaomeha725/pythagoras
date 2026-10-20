import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_lesson_row.dart';

class CourseLessonsList extends StatelessWidget {
  final List<CourseLesson> lessons;
  final bool showStatuses;
  final String? selectedLessonId;
  final Function(CourseLesson)? onLessonTap;
  final bool tabletLandscape;

  const CourseLessonsList({
    super.key,
    required this.lessons,
    this.showStatuses = false,
    this.selectedLessonId,
    this.onLessonTap,
    this.tabletLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(lessons.length, (i) {
        final lesson = lessons[i];
        final isLast = i == lessons.length - 1;
        return Column(
          children: [
            CourseLessonRow(
              lesson: lesson,
              showStatuses: showStatuses,
              isSelected: lesson.id == selectedLessonId,
              onTap: onLessonTap != null ? () => onLessonTap!(lesson) : null,
              tabletLandscape: tabletLandscape,
            ),
            if (!isLast)
              Divider(
                height: 1,
                color: AppLightColors.primary.withValues(alpha: 0.1),
                indent: tabletLandscape ? 16 : 16.w,
                endIndent: tabletLandscape ? 16 : 16.w,
              ),
          ],
        );
      }),
    );
  }
}

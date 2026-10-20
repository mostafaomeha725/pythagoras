import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_lesson_duration.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_lesson_icon.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_lesson_info.dart';

class CourseLessonRow extends StatelessWidget {
  final CourseLesson lesson;
  final bool showStatuses;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool tabletLandscape;

  const CourseLessonRow({
    super.key,
    required this.lesson,
    required this.showStatuses,
    this.isSelected = false,
    this.onTap,
    this.tabletLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaying = isSelected || (showStatuses && lesson.status == CourseLessonStatus.playing);
    final isCompleted = showStatuses && lesson.status == CourseLessonStatus.completed;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isPlaying ? const Color(0xFFF6EEF5) : Colors.transparent,
        padding: tabletLandscape
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
            : EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Play icon + title ─ grouped, far RIGHT
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CourseLessonIcon(
                  isCompleted: isCompleted,
                  isPlaying: isPlaying,
                  tabletLandscape: tabletLandscape,
                ),
                SizedBox(width: tabletLandscape ? 12 : 10.w),
                // Lesson title & subtitle
                Expanded(
                  child: CourseLessonInfo(
                    title: lesson.title,
                    isPlaying: isPlaying,
                    isCompleted: isCompleted,
                    tabletLandscape: tabletLandscape,
                  ),
                ),
              ],
            ),
          ),
          // Duration ─ far LEFT
          CourseLessonDuration(
            durationMinutes: lesson.durationMinutes,
            showStatuses: showStatuses,
            isPlaying: isPlaying,
            tabletLandscape: tabletLandscape,
          ),
        ],
      ),
    ));
  }
}


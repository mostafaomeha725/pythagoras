import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_tablet_current_lesson_info.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_player_placeholder.dart';

/// Video player and lesson details pane for Tablet Landscape (flex: 6).
class CourseTabletVideoPlayerPane extends StatelessWidget {
  final CourseDetail course;
  final CourseLesson? selectedLesson;
  final CourseDetail updatedCourse;

  const CourseTabletVideoPlayerPane({
    super.key,
    required this.course,
    required this.selectedLesson,
    required this.updatedCourse,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 6,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CourseVideoPlayerPlaceholder(
              imageUrl: course.imageUrl ?? '',
              videoUrl: selectedLesson?.videoUrl,
              videoType: selectedLesson?.videoType,
            ),
            const SizedBox(height: 16),
            CourseTabletCurrentLessonInfo(
              selectedLesson: selectedLesson,
              course: updatedCourse,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

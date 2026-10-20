import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_tablet_recorded_chapters_list.dart';

/// Curriculum Chapters & Lessons Playlist pane for Tablet Landscape (flex: 4).
class CourseTabletPlaylistPane extends StatelessWidget {
  final CourseDetail course;
  final CourseLesson? selectedLesson;
  final ValueChanged<CourseLesson> onLessonTap;

  const CourseTabletPlaylistPane({
    super.key,
    required this.course,
    required this.selectedLesson,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: CourseTabletRecordedChaptersList(
            course: course,
            selectedLesson: selectedLesson,
            onLessonTap: onLessonTap,
          ),
        ),
      ),
    );
  }
}

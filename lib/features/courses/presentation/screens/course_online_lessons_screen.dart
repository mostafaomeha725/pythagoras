import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/course_online_lessons_screen_body.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/course_online_lessons_tablet_landscape.dart';

class CourseOnlineLessonsScreen extends StatelessWidget {
  final CourseDetail course;

  const CourseOnlineLessonsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletLandscape =
            constraints.maxWidth >= 900 &&
            constraints.maxHeight >= 600 &&
            constraints.maxWidth > constraints.maxHeight;

        if (isTabletLandscape) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: SafeArea(
              child: CourseOnlineLessonsTabletLandscape(course: course),
            ),
          );
        }

        // Original layout for Mobile Portrait & Tablet Portrait completely untouched
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const CourseDetailAppBar(title: 'الحصص الأونلاين'),
          body: SafeArea(child: CourseOnlineLessonsScreenBody(course: course)),
        );
      },
    );
  }
}

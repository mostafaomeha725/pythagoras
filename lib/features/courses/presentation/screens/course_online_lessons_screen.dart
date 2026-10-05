import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/course_online_lessons_screen_body.dart';

class CourseOnlineLessonsScreen extends StatelessWidget {
  final CourseDetail course;

  const CourseOnlineLessonsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CourseDetailAppBar(title: 'الحصص الأونلاين'),
      body: SafeArea(child: CourseOnlineLessonsScreenBody(course: course)),
    );
  }
}

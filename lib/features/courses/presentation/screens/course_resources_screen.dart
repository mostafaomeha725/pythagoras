import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_resources_screen_body.dart';

class CourseResourcesScreen extends StatelessWidget {
  final CourseDetail course;

  const CourseResourcesScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CourseDetailAppBar(title: 'الموارد'),
      body: SafeArea(child: CourseResourcesScreenBody(course: course)),
    );
  }
}

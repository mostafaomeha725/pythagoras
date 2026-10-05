import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_sections_screen_body.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';

class CourseSectionsScreen extends StatelessWidget {
  final CourseDetail course;
  final int? selectedChapterId;
  const CourseSectionsScreen({super.key, required this.course, this.selectedChapterId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CourseDetailAppBar(title: 'أقسام الدورة'),
      body: SafeArea(child: CourseSectionsScreenBody(course: course, selectedChapterId: selectedChapterId)),
    );
  }
}

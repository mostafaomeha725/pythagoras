import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_exams/course_exams_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/course_exams_screen_body.dart';

class CourseExamsScreen extends StatelessWidget {
  final CourseDetail course;

  const CourseExamsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<CourseExamsCubit>()..fetchExamsAndAssignments(course.id),
      child: Scaffold(
        appBar: const CourseDetailAppBar(title: 'الامتحانات والواجبات'),
        body: SafeArea(child: CourseExamsScreenBody(course: course)),
      ),
    );
  }
}

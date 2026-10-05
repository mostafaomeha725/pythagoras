import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/presentation/cubit/quiz/quiz_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_screen_body.dart';

class QuizScreen extends StatelessWidget {
  final CourseQuiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QuizCubit>()..startQuiz(quiz.id),
      child: Scaffold(
        appBar: CourseDetailAppBar(title: quiz.title),
        body: SafeArea(
          child: QuizScreenBody(quiz: quiz),
        ),
      ),
    );
  }
}

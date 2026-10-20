import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/presentation/cubit/quiz/quiz_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_screen_body.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_tablet_landscape.dart';

class QuizScreen extends StatelessWidget {
  final CourseQuiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QuizCubit>()..startQuiz(quiz.id),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTabletLandscape =
              ResponsiveHelper.isTabletLandscape(context, constraints) ||
              (constraints.maxWidth >= 900 &&
                  constraints.maxWidth > constraints.maxHeight);

          if (isTabletLandscape) {
            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              body: SafeArea(child: QuizTabletLandscape(quiz: quiz)),
            );
          }

          // Original layout for Mobile Portrait & Tablet Portrait completely untouched
          return Scaffold(
            appBar: CourseDetailAppBar(title: quiz.title),
            body: SafeArea(child: QuizScreenBody(quiz: quiz)),
          );
        },
      ),
    );
  }
}

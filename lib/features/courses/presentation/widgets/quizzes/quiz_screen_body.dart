import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/presentation/cubit/quiz/quiz_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/quiz/quiz_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_progress_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_question_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_options_grid.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_action_buttons.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_empty_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_shimmer.dart';
import 'package:go_router/go_router.dart';

class QuizScreenBody extends StatelessWidget {
  final CourseQuiz quiz;

  const QuizScreenBody({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizCubit, QuizState>(
      listener: (context, state) {
        if (state is QuizCompleted) {
          // Navigate to results screen or show success
          showSuccess('تم إنهاء الامتحان بنجاح');
          context.pop(true);
        } else if (state is QuizError) {
          showError(state.message);
        }
      },
      builder: (context, state) {
        if (state is QuizLoading || state is QuizInitial) {
          return const QuizShimmer();
        }

        if (state is QuizLoaded) {
          if (state.questions.isEmpty) {
            return const QuizEmptyState();
          }

          final question = state.questions[state.currentQuestionIndex];
          final selectedOptionId = state.selectedOptions[question.id];

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      QuizProgressCard(
                        currentIndex: state.currentQuestionIndex,
                        totalQuestions: state.questions.length,
                        points: question.points,
                      ),
                      SizedBox(height: 24.h),
                      QuizQuestionCard(question: question),
                      SizedBox(height: 24.h),
                      AppText(
                        'اختر الإجابة الصحيحة',
                        style: font16w700.copyWith(
                          color: const Color(0xFF1E1E2D),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      QuizOptionsGrid(
                        question: question,
                        selectedOptionId: selectedOptionId,
                        onOptionSelected: (optionId) {
                          context.read<QuizCubit>().selectOption(
                            question.id,
                            optionId,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              QuizActionButtons(
                isFirst: state.currentQuestionIndex == 0,
                isLast:
                    state.currentQuestionIndex == state.questions.length - 1,
                isSubmitting: state.isSubmitting,
                onNext: () {
                  context.read<QuizCubit>().nextQuestion();
                },
                onPrevious: () {
                  context.read<QuizCubit>().previousQuestion();
                },
                onSubmit: () {
                  context.read<QuizCubit>().submitQuiz(quiz.id);
                },
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

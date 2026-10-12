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
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_timer_header.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_empty_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_shimmer.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';
import 'package:go_router/go_router.dart';

class QuizScreenBody extends StatefulWidget {
  final CourseQuiz quiz;

  const QuizScreenBody({super.key, required this.quiz});

  @override
  State<QuizScreenBody> createState() => _QuizScreenBodyState();
}

class _QuizScreenBodyState extends State<QuizScreenBody> {
  bool _isTimeExpired = false;
  bool _hasHandledExpiry = false;

  int _resolveInitialSeconds(QuizState state) {
    if (state is QuizLoaded) {
      final remaining = state.attempt.activeAttempt?.remainingTimeMinutes;
      if (remaining != null && remaining > 0) {
        return remaining * 60;
      }
    }
    final activeRemaining = widget.quiz.activeAttempt?.remainingTimeMinutes;
    if (activeRemaining != null && activeRemaining > 0) {
      return activeRemaining * 60;
    }
    if (widget.quiz.duration > 0) {
      return widget.quiz.duration * 60;
    }
    return 30 * 60;
  }

  void _handleTimeExpired() {
    if (_isTimeExpired || _hasHandledExpiry) return;
    setState(() {
      _isTimeExpired = true;
      _hasHandledExpiry = true;
    });

    final cubit = context.read<QuizCubit>();
    if (cubit.state is QuizLoaded) {
      showLoading(status: 'انتهى الوقت، جاري تسليم الامتحان...');
      cubit.submitQuiz(widget.quiz.id);
    } else {
      showInfo('انتهى وقت الامتحان');
      if (mounted) {
        context.pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizCubit, QuizState>(
      listener: (context, state) {
        if (state is QuizCompleted) {
          if (_isTimeExpired) {
            showInfo('انتهى وقت الامتحان وتم تسليم إجاباتك تلقائيًا');
          } else {
            showSuccess('تم إنهاء الامتحان بنجاح');
          }
          context.pop(true);
        } else if (state is QuizError) {
          if (_isTimeExpired) {
            showInfo(state.message);
            context.pop(true);
          } else {
            showError(state.message);
          }
        } else if (state is QuizLoaded && state.actionError != null) {
          showError(state.actionError!);
        }
      },
      builder: (context, state) {
        final isSubmitting = state is QuizLoaded ? state.isSubmitting : false;

        return Column(
          children: [
            // Pinned fixed countdown timer at the top
            QuizTimerHeader(
              initialSeconds: _resolveInitialSeconds(state),
              isPaused: isSubmitting || _isTimeExpired,
              onTimeExpired: _handleTimeExpired,
            ),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, QuizState state) {
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
                    style: font16w700.copyWith(color: const Color(0xFF1E1E2D)),
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
            isLast: state.currentQuestionIndex == state.questions.length - 1,
            isSubmitting: state.isSubmitting,
            onNext: () {
              context.read<QuizCubit>().nextQuestion(quizId: widget.quiz.id);
            },
            onPrevious: () {
              context.read<QuizCubit>().previousQuestion();
            },
            onSubmit: () {
              context.read<QuizCubit>().submitQuiz(widget.quiz.id);
            },
          ),
        ],
      );
    }
    if (state is QuizError) {
      return NoInternetWidget(
        message: state.message,
        onRetry: () => context.read<QuizCubit>().startQuiz(widget.quiz.id),
      );
    }

    return const SizedBox.shrink();
  }
}

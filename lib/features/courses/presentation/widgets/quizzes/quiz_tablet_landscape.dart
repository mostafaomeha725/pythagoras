import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/presentation/cubit/quiz/quiz_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/quiz/quiz_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_empty_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_tablet_action_buttons.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_tablet_options_list.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_tablet_progress_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_tablet_question_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_tablet_timer_header.dart';

/// Dedicated Tablet Landscape layout for [QuizScreen].
/// Features a two-column layout:
/// - Right Column (in RTL): Progress indicator and Question card with image
/// - Left Column (in RTL): Options list and action navigation buttons
class QuizTabletLandscape extends StatefulWidget {
  final CourseQuiz quiz;

  const QuizTabletLandscape({super.key, required this.quiz});

  @override
  State<QuizTabletLandscape> createState() => _QuizTabletLandscapeState();
}

class _QuizTabletLandscapeState extends State<QuizTabletLandscape> {
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
            // Top Bar with back button and quiz title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: CourseDetailTabletTopBar(title: widget.quiz.title),
            ),

            // Pinned countdown timer header for Tablet
            QuizTabletTimerHeader(
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

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Right Column: Progress & Question
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  QuizTabletProgressCard(
                    currentIndex: state.currentQuestionIndex,
                    totalQuestions: state.questions.length,
                    points: question.points,
                  ),
                  const SizedBox(height: 16),
                  QuizTabletQuestionCard(question: question),
                ],
              ),
            ),

            const SizedBox(width: 20),

            // Left Column: Options & Action Buttons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText(
                    'اختر الإجابة الصحيحة',
                    style: font16w700.copyWith(
                      color: const Color(0xFF1E1E2D),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  QuizTabletOptionsList(
                    question: question,
                    selectedOptionId: selectedOptionId,
                    onOptionSelected: (optionId) {
                      context.read<QuizCubit>().selectOption(
                            question.id,
                            optionId,
                          );
                    },
                  ),
                  const SizedBox(height: 16),
                  QuizTabletActionButtons(
                    isFirst: state.currentQuestionIndex == 0,
                    isLast:
                        state.currentQuestionIndex == state.questions.length - 1,
                    isSubmitting: state.isSubmitting,
                    onNext: () {
                      context
                          .read<QuizCubit>()
                          .nextQuestion(quizId: widget.quiz.id);
                    },
                    onPrevious: () {
                      context.read<QuizCubit>().previousQuestion();
                    },
                    onSubmit: () {
                      context.read<QuizCubit>().submitQuiz(widget.quiz.id);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
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

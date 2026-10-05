import 'package:pythagoras/features/courses/domain/entities/quiz_attempt.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_question.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_result.dart';

abstract class QuizState {}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final int currentQuestionIndex;
  final QuizAttempt attempt;
  final List<QuizQuestion> questions;
  final Map<int, int?> selectedOptions; // questionId -> optionId
  final bool isSubmitting;

  QuizLoaded({
    required this.currentQuestionIndex,
    required this.attempt,
    required this.questions,
    this.selectedOptions = const {},
    this.isSubmitting = false,
  });

  QuizLoaded copyWith({
    int? currentQuestionIndex,
    QuizAttempt? attempt,
    List<QuizQuestion>? questions,
    Map<int, int?>? selectedOptions,
    bool? isSubmitting,
  }) {
    return QuizLoaded(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      attempt: attempt ?? this.attempt,
      questions: questions ?? this.questions,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class QuizError extends QuizState {
  final String message;
  QuizError(this.message);
}

class QuizCompleted extends QuizState {
  final QuizResult result;
  QuizCompleted(this.result);
}

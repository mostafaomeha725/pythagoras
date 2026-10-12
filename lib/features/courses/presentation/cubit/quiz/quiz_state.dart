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
  final Map<int, int> submittedOptions; // questionId -> optionId (confirmed via submitAnswer)
  final bool isSubmitting;
  final String? actionError;

  QuizLoaded({
    required this.currentQuestionIndex,
    required this.attempt,
    required this.questions,
    this.selectedOptions = const {},
    this.submittedOptions = const {},
    this.isSubmitting = false,
    this.actionError,
  });

  QuizLoaded copyWith({
    int? currentQuestionIndex,
    QuizAttempt? attempt,
    List<QuizQuestion>? questions,
    Map<int, int?>? selectedOptions,
    Map<int, int>? submittedOptions,
    bool? isSubmitting,
    String? actionError,
  }) {
    return QuizLoaded(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      attempt: attempt ?? this.attempt,
      questions: questions ?? this.questions,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      submittedOptions: submittedOptions ?? this.submittedOptions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionError: actionError,
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

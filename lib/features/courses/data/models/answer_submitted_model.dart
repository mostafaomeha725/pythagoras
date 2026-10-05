import 'package:pythagoras/features/courses/domain/entities/answer_submitted.dart';

class AnswerSubmittedModel extends AnswerSubmitted {
  const AnswerSubmittedModel({
    required super.id,
    required super.quizAttemptId,
    required super.questionId,
    required super.optionId,
    super.selectedAnswer,
    required super.isCorrect,
  });

  factory AnswerSubmittedModel.fromJson(Map<String, dynamic> json) {
    return AnswerSubmittedModel(
      id: json['id'] as int,
      quizAttemptId: json['quiz_attempt_id'] as int,
      questionId: json['question_id'] as int,
      optionId: json['option_id'] as int,
      selectedAnswer: json['selected_answer']?.toString(),
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }
}

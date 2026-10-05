class AnswerSubmitted {
  final int id;
  final int quizAttemptId;
  final int questionId;
  final int optionId;
  final String? selectedAnswer;
  final bool isCorrect;

  const AnswerSubmitted({
    required this.id,
    required this.quizAttemptId,
    required this.questionId,
    required this.optionId,
    this.selectedAnswer,
    required this.isCorrect,
  });
}

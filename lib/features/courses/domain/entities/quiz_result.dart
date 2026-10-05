import 'package:pythagoras/features/courses/domain/entities/question_option.dart';

class QuizResult {
  final int id;
  final int quizId;
  final int userId;
  final num score;
  final num maxScore;
  final num percentage;
  final int attempts;
  final String completedAt;
  final bool isPassed;
  final QuizResultDetails quiz;
  final QuizUser user;
  final List<QuizResultAnswer> answers;
  final QuizSummary summary;

  const QuizResult({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.attempts,
    required this.completedAt,
    required this.isPassed,
    required this.quiz,
    required this.user,
    required this.answers,
    required this.summary,
  });
}

class QuizResultDetails {
  final int id;
  final String title;
  final String? description;
  final int passingScore;
  final int maxAttempts;
  final int duration;

  const QuizResultDetails({
    required this.id,
    required this.title,
    this.description,
    required this.passingScore,
    required this.maxAttempts,
    required this.duration,
  });
}

class QuizUser {
  final int id;
  final String name;
  final String? email;
  final String? avatar;

  const QuizUser({
    required this.id,
    required this.name,
    this.email,
    this.avatar,
  });
}

class QuizResultAnswer {
  final int id;
  final int questionId;
  final String? questionText;
  final String? questionImageUrl;
  final String questionType;
  final int? optionId;
  final dynamic selectedAnswer;
  final dynamic correctAnswer;
  final bool isCorrect;
  final int points;
  final List<QuestionOption> options;

  const QuizResultAnswer({
    required this.id,
    required this.questionId,
    this.questionText,
    this.questionImageUrl,
    required this.questionType,
    this.optionId,
    this.selectedAnswer,
    this.correctAnswer,
    required this.isCorrect,
    required this.points,
    required this.options,
  });
}

class QuizSummary {
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final num totalPointsEarned;
  final num totalPossiblePoints;

  const QuizSummary({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.totalPointsEarned,
    required this.totalPossiblePoints,
  });
}

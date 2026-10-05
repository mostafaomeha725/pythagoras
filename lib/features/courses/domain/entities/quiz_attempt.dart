import 'package:pythagoras/features/courses/domain/entities/quiz_active_attempt.dart';

class QuizAttempt {
  final int id;
  final String quizId;
  final int userId;
  final int attemptNumber;
  final String startedAt;
  final String? completedAt;
  final QuizActiveAttempt? activeAttempt;

  const QuizAttempt({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.attemptNumber,
    required this.startedAt,
    this.completedAt,
    this.activeAttempt,
  });
}

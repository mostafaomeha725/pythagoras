import 'package:pythagoras/features/courses/domain/entities/quiz_attempt.dart';
import 'package:pythagoras/features/courses/data/models/quiz_active_attempt_model.dart';

class QuizAttemptModel extends QuizAttempt {
  const QuizAttemptModel({
    required super.id,
    required super.quizId,
    required super.userId,
    required super.attemptNumber,
    required super.startedAt,
    super.completedAt,
    super.activeAttempt,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: json['id'] as int,
      quizId: json['quiz_id'].toString(),
      userId: json['user_id'] as int,
      attemptNumber: json['attempt_number'] as int? ?? 1,
      startedAt: json['started_at'] as String? ?? '',
      completedAt: json['completed_at'] as String?,
      activeAttempt: json['active_attempt'] != null
          ? QuizActiveAttemptModel.fromJson(json['active_attempt'])
          : null,
    );
  }
}

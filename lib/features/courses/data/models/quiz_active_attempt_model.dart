import 'package:pythagoras/features/courses/domain/entities/quiz_active_attempt.dart';

class QuizActiveAttemptModel extends QuizActiveAttempt {
  const QuizActiveAttemptModel({
    super.attemptId,
    super.startedAt,
    required super.timeElapsedMinutes,
    required super.remainingTimeMinutes,
    super.remainingTimeFormatted,
    required super.isExpired,
    super.message,
  });

  factory QuizActiveAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizActiveAttemptModel(
      attemptId: json['attempt_id'] as int?,
      startedAt: json['started_at'] as String?,
      timeElapsedMinutes: json['time_elapsed_minutes'] as int? ?? 0,
      remainingTimeMinutes: json['remaining_time_minutes'] as int? ?? 0,
      remainingTimeFormatted: json['remaining_time_formatted'] as String?,
      isExpired: json['is_expired'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}

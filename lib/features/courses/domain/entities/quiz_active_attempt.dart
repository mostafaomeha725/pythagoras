class QuizActiveAttempt {
  final int? attemptId;
  final String? startedAt;
  final int timeElapsedMinutes;
  final int remainingTimeMinutes;
  final String? remainingTimeFormatted;
  final bool isExpired;
  final String? message;

  const QuizActiveAttempt({
    this.attemptId,
    this.startedAt,
    required this.timeElapsedMinutes,
    required this.remainingTimeMinutes,
    this.remainingTimeFormatted,
    required this.isExpired,
    this.message,
  });
}

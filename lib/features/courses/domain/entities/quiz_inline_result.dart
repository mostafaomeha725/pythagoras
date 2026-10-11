/// Lightweight result summary embedded directly in the `api/courses/{id}/quizzes`
/// response. This is different from the full [QuizResult] returned by the
/// (now-removed) `api/quizzes/{id}/result` endpoint.
class QuizInlineResult {
  final num score;
  final num maxScore;
  final num percentage;
  final bool isPassed;
  final num bestScore;
  final num bestPercentage;
  final String? completedAt;

  const QuizInlineResult({
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.isPassed,
    required this.bestScore,
    required this.bestPercentage,
    this.completedAt,
  });
}

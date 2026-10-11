import 'package:pythagoras/features/courses/domain/entities/quiz_inline_result.dart';

class QuizInlineResultModel extends QuizInlineResult {
  const QuizInlineResultModel({
    required super.score,
    required super.maxScore,
    required super.percentage,
    required super.isPassed,
    required super.bestScore,
    required super.bestPercentage,
    super.completedAt,
  });

  factory QuizInlineResultModel.fromJson(Map<String, dynamic> json) {
    return QuizInlineResultModel(
      score: (json['score'] as num?) ?? 0,
      maxScore: (json['max_score'] as num?) ?? 0,
      percentage: (json['percentage'] as num?) ?? 0,
      isPassed: json['is_passed'] as bool? ?? false,
      bestScore: (json['best_score'] as num?) ?? 0,
      bestPercentage: (json['best_percentage'] as num?) ?? 0,
      completedAt: json['completed_at'] as String?,
    );
  }
}

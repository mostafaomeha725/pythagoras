import 'package:pythagoras/features/courses/domain/entities/quiz_result.dart';
import 'package:pythagoras/features/courses/data/models/question_option_model.dart';

class QuizResultModel extends QuizResult {
  const QuizResultModel({
    required super.id,
    required super.quizId,
    required super.userId,
    required super.score,
    required super.maxScore,
    required super.percentage,
    required super.attempts,
    required super.completedAt,
    required super.isPassed,
    required super.quiz,
    required super.user,
    required super.answers,
    required super.summary,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: json['id'] as int,
      quizId: json['quiz_id'] as int,
      userId: json['user_id'] as int,
      score: json['score'] as num? ?? 0,
      maxScore: json['max_score'] as num? ?? 0,
      percentage: json['percentage'] as num? ?? 0,
      attempts: json['attempts'] as int? ?? 1,
      completedAt: json['completed_at'] as String? ?? '',
      isPassed: json['is_passed'] as bool? ?? false,
      quiz: QuizResultDetailsModel.fromJson(json['quiz'] as Map<String, dynamic>),
      user: QuizUserModel.fromJson(json['user'] as Map<String, dynamic>),
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) => QuizResultAnswerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: QuizSummaryModel.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }
}

class QuizResultDetailsModel extends QuizResultDetails {
  const QuizResultDetailsModel({
    required super.id,
    required super.title,
    super.description,
    required super.passingScore,
    required super.maxAttempts,
    required super.duration,
  });

  factory QuizResultDetailsModel.fromJson(Map<String, dynamic> json) {
    return QuizResultDetailsModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      passingScore: json['passing_score'] as int? ?? 0,
      maxAttempts: json['max_attempts'] as int? ?? 1,
      duration: json['duration'] as int? ?? 0,
    );
  }
}

class QuizUserModel extends QuizUser {
  const QuizUserModel({
    required super.id,
    required super.name,
    super.email,
    super.avatar,
  });

  factory QuizUserModel.fromJson(Map<String, dynamic> json) {
    return QuizUserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
}

class QuizResultAnswerModel extends QuizResultAnswer {
  const QuizResultAnswerModel({
    required super.id,
    required super.questionId,
    super.questionText,
    super.questionImageUrl,
    required super.questionType,
    super.optionId,
    super.selectedAnswer,
    super.correctAnswer,
    required super.isCorrect,
    required super.points,
    required super.options,
  });

  factory QuizResultAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuizResultAnswerModel(
      id: json['id'] as int,
      questionId: json['question_id'] as int,
      questionText: json['question_text'] as String?,
      questionImageUrl: json['question_image_url'] as String?,
      questionType: json['question_type'] as String? ?? 'multiple_choice',
      optionId: json['option_id'] as int?,
      selectedAnswer: json['selected_answer'],
      correctAnswer: json['correct_answer'],
      isCorrect: json['is_correct'] as bool? ?? false,
      points: json['points'] as int? ?? 0,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => QuestionOptionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class QuizSummaryModel extends QuizSummary {
  const QuizSummaryModel({
    required super.totalQuestions,
    required super.correctAnswers,
    required super.incorrectAnswers,
    required super.totalPointsEarned,
    required super.totalPossiblePoints,
  });

  factory QuizSummaryModel.fromJson(Map<String, dynamic> json) {
    return QuizSummaryModel(
      totalQuestions: json['total_questions'] as int? ?? 0,
      correctAnswers: json['correct_answers'] as int? ?? 0,
      incorrectAnswers: json['incorrect_answers'] as int? ?? 0,
      totalPointsEarned: json['total_points_earned'] as num? ?? 0,
      totalPossiblePoints: json['total_possible_points'] as num? ?? 0,
    );
  }
}

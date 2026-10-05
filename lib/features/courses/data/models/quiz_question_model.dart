import 'package:pythagoras/features/courses/domain/entities/quiz_question.dart';
import 'package:pythagoras/features/courses/data/models/question_option_model.dart';

class QuizQuestionModel extends QuizQuestion {
  const QuizQuestionModel({
    required super.id,
    super.questionText,
    super.imageUrl,
    required super.questionType,
    required super.points,
    required super.order,
    required super.isActive,
    required super.options,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'] as int,
      questionText: json['question_text'] as String?,
      imageUrl: json['image_url'] as String?,
      questionType: json['question_type'] as String? ?? 'multiple_choice',
      points: json['points'] as int? ?? 1,
      order: json['order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => QuestionOptionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

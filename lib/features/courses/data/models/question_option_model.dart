import 'package:pythagoras/features/courses/domain/entities/question_option.dart';

class QuestionOptionModel extends QuestionOption {
  const QuestionOptionModel({
    required super.id,
    super.text,
    super.imageUrl,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      id: json['id'] as int,
      text: json['text'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}

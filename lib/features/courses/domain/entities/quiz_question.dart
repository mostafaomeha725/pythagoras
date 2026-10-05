import 'package:pythagoras/features/courses/domain/entities/question_option.dart';

class QuizQuestion {
  final int id;
  final String? questionText;
  final String? imageUrl;
  final String questionType;
  final int points;
  final int order;
  final bool isActive;
  final List<QuestionOption> options;

  const QuizQuestion({
    required this.id,
    this.questionText,
    this.imageUrl,
    required this.questionType,
    required this.points,
    required this.order,
    required this.isActive,
    required this.options,
  });
}

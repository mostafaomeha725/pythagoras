import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/data/models/quiz_active_attempt_model.dart';
import 'package:pythagoras/features/courses/data/models/quiz_inline_result_model.dart';

class CourseQuizModel extends CourseQuiz {
  const CourseQuizModel({
    required super.id,
    required super.title,
    super.description,
    required super.duration,
    required super.passingScore,
    required super.totalQuestions,
    required super.totalMarks,
    required super.isActive,
    required super.maxAttempts,
    required super.canAttempt,
    super.remainingAttempts,
    required super.currentAttempts,
    super.courseId,
    super.chapterId,
    super.activeAttempt,
    super.inlineResult,
  });

  factory CourseQuizModel.fromJson(Map<String, dynamic> json) {
    return CourseQuizModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      duration: json['duration'] as int? ?? 0,
      passingScore: json['passing_score'] as int? ?? 0,
      totalQuestions: json['total_questions'] as int? ?? 0,
      totalMarks: json['total_marks'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
      maxAttempts: json['max_attempts'] as int? ?? 0,
      canAttempt: json['can_attempt'] as bool? ?? false,
      remainingAttempts: json['remaining_attempts'] as int?,
      currentAttempts: json['current_attempts'] as int? ?? 0,
      courseId: json['course_id'] as int?,
      chapterId: json['chapter_id'] as int?,
      activeAttempt: json['active_attempt'] != null
          ? QuizActiveAttemptModel.fromJson(json['active_attempt'])
          : null,
      inlineResult: json['result'] != null
          ? QuizInlineResultModel.fromJson(
              json['result'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

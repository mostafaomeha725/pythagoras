import 'package:pythagoras/features/courses/domain/entities/quiz_active_attempt.dart';

class CourseQuiz {
  final int id;
  final String title;
  final String? description;
  final int duration;
  final int passingScore;
  final int totalQuestions;
  final int totalMarks;
  final bool isActive;
  final int maxAttempts;
  final bool canAttempt;
  final int? remainingAttempts;
  final int currentAttempts;
  final int? courseId;
  final int? chapterId;
  final QuizActiveAttempt? activeAttempt;

  const CourseQuiz({
    required this.id,
    required this.title,
    this.description,
    required this.duration,
    required this.passingScore,
    required this.totalQuestions,
    required this.totalMarks,
    required this.isActive,
    required this.maxAttempts,
    required this.canAttempt,
    this.remainingAttempts,
    required this.currentAttempts,
    this.courseId,
    this.chapterId,
    this.activeAttempt,
  });
}

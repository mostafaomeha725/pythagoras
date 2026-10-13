import 'package:pythagoras/features/courses/domain/entities/quiz_active_attempt.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_inline_result.dart';

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
  final QuizInlineResult? inlineResult;

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
    this.inlineResult,
  });

  /// Whether this is the student's first attempt (not taken yet).
  bool get isFirstAttempt => currentAttempts == 0;

  /// Whether the quiz has a set maximum number of attempts.
  bool get hasAttemptLimit => maxAttempts > 0;

  /// Returns the number of remaining attempts safely calculated.
  int get calculatedRemainingAttempts {
    if (remainingAttempts != null) {
      return remainingAttempts! > 0 ? remainingAttempts! : 0;
    }
    if (maxAttempts > 0) {
      final rem = maxAttempts - currentAttempts;
      return rem > 0 ? rem : 0;
    }
    return 0;
  }

  /// Human-readable label for remaining attempts in Arabic.
  String get remainingAttemptsLabel {
    final remaining = calculatedRemainingAttempts;
    if (maxAttempts > 0 || remainingAttempts != null) {
      if (remaining <= 0) {
        return 'لا توجد محاولات متبقية';
      } else if (remaining == 1) {
        return 'باقي محاولة واحدة';
      } else if (remaining == 2) {
        return 'باقي محاولتان';
      } else if (remaining >= 3 && remaining <= 10) {
        return 'باقي $remaining محاولات';
      } else {
        return 'باقي $remaining محاولة';
      }
    }
    return 'محاولات غير محدودة';
  }
}

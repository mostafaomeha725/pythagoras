import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:pythagoras/features/courses/domain/entities/assignment_submission.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_result.dart';

enum CourseTaskType { assignment, quiz }

class CourseTaskItem {
  final CourseTaskType type;
  
  // Assignment specific
  final CourseAssignment? assignment;
  final AssignmentSubmission? submission;
  
  // Quiz specific
  final CourseQuiz? quiz;
  final QuizResult? quizResult;

  CourseTaskItem.assignment({
    required this.assignment,
    this.submission,
  }) : type = CourseTaskType.assignment, quiz = null, quizResult = null;

  CourseTaskItem.quiz({
    required this.quiz,
    this.quizResult,
  }) : type = CourseTaskType.quiz, assignment = null, submission = null;
}

abstract class CourseExamsState {}

class CourseExamsInitial extends CourseExamsState {}

class CourseExamsLoading extends CourseExamsState {}

class CourseExamsLoaded extends CourseExamsState {
  final List<CourseTaskItem> upcomingTasks;
  final List<CourseTaskItem> completedTasks;

  CourseExamsLoaded({
    required this.upcomingTasks,
    required this.completedTasks,
  });
}

class CourseExamsError extends CourseExamsState {
  final String message;
  CourseExamsError(this.message);
}

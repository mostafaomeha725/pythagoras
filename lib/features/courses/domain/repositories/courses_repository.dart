import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';
import 'package:pythagoras/features/courses/domain/entities/course.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:pythagoras/features/courses/domain/entities/assignment_submission.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_question.dart';
import 'package:pythagoras/features/courses/domain/entities/live_session.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_attempt.dart';
import 'package:pythagoras/features/courses/domain/entities/answer_submitted.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_result.dart';
import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';
import 'package:pythagoras/features/courses/domain/entities/course_review.dart';
import 'package:pythagoras/features/courses/domain/entities/course_reviews_data.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';

abstract class CoursesRepository {
  Future<Either<Failure, List<StudentClass>>> getClasses({
    bool fromCache = false,
  });
  Future<Either<Failure, List<Course>>> getCourses({
    int? classId,
    int? semester,
    bool fromCache = false,
  });
  Future<Either<Failure, CourseDetail>> getCourseDetails(
    int courseId, {
    bool fromCache = false,
  });
  Future<Either<Failure, CourseDetail>> getCourseCurriculum(
    int courseId, {
    bool fromCache = false,
  });
  Future<Either<Failure, String>> requestCourse(int courseId);
  Future<Either<Failure, String>> requestChapter(int chapterId);
  Future<Either<Failure, List<CourseLesson>>> getChapterVideos(
    int chapterId, {
    bool fromCache = false,
  });
  Future<Either<Failure, String>> completeVideo(int videoId);
  Future<Either<Failure, String>> completeLesson(int lessonId);
  Future<Either<Failure, List<CourseAssignment>>> getCourseAssignments(
    int courseId, {
    bool fromCache = false,
  });
  Future<Either<Failure, CourseAssignment>> getAssignmentDetails(
    int assignmentId,
  );
  Future<Either<Failure, AssignmentSubmission>> submitAssignment({
    required int assignmentId,
    String? notes,
    String? filePath,
    String? fileName,
  });
  Future<Either<Failure, List<AssignmentSubmission>>> getAssignmentSubmissions(
    int assignmentId, {
    bool fromCache = false,
  });

  // Quizzes
  Future<Either<Failure, List<CourseQuiz>>> getCourseQuizzes(
    int courseId, {
    bool fromCache = false,
  });
  Future<Either<Failure, CourseQuiz>> getQuizDetails(int quizId);
  Future<Either<Failure, List<QuizQuestion>>> getQuizQuestions(int quizId);
  Future<Either<Failure, QuizAttempt>> startQuizAttempt(int quizId);
  Future<Either<Failure, AnswerSubmitted>> submitAnswer({
    required int quizId,
    required int quizAttemptId,
    required int questionId,
    int? optionId,
    dynamic selectedAnswer, // in case of text/other types
  });
  Future<Either<Failure, QuizResult>> submitQuiz({
    required int quizId,
    required List<Map<String, dynamic>>
    answers, // e.g., [{"question_id": 1, "answer_id": 2}]
  });
  Future<Either<Failure, QuizResult>> getQuizResult(
    int quizId, {
    bool fromCache = false,
  });
  Future<Either<Failure, List<LiveSession>>> getLiveSessions(
    int courseId, {
    bool fromCache = false,
  });
  Future<Either<Failure, List<CourseResource>>> getCourseResources(
    int courseId, {
    bool fromCache = false,
  });

  // Reviews
  Future<Either<Failure, CourseReviewsData>> getCourseReviews(
    int courseId, {
    bool fromCache = false,
  });
  Future<Either<Failure, CourseReview>> addCourseReview({
    required int courseId,
    required double rating,
    required String comment,
  });
}

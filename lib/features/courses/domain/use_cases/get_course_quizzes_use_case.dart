import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class GetCourseQuizzesUseCase {
  final CoursesRepository repository;

  GetCourseQuizzesUseCase(this.repository);

  Future<Either<Failure, List<CourseQuiz>>> call(int courseId, {bool fromCache = false}) async {
    return await repository.getCourseQuizzes(courseId, fromCache: fromCache);
  }
}

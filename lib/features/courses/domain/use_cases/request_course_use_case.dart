import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class RequestCourseUseCase {
  final CoursesRepository repository;

  RequestCourseUseCase(this.repository);

  Future<Either<Failure, String>> call(int courseId) {
    return repository.requestCourse(courseId);
  }
}

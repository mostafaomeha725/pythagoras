import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

/// iOS-only use case: sends a direct course enrollment request
/// to `POST /api/request/course/direct` and returns the server message.
class RequestCourseDirectUseCase {
  final CoursesRepository repository;

  RequestCourseDirectUseCase(this.repository);

  Future<Either<Failure, String>> call(int courseId) {
    return repository.requestCourseDirect(courseId);
  }
}

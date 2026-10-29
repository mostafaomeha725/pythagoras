import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class EnrollCourseUseCase {
  final CoursesRepository repository;

  EnrollCourseUseCase(this.repository);

  Future<Either<Failure, String>> call(int courseId) {
    return repository.enrollCourse(courseId);
  }
}

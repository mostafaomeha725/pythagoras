import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class GetCourseDetailsUseCase {
  final CoursesRepository repository;

  GetCourseDetailsUseCase(this.repository);

  Future<Either<Failure, CourseDetail>> call(int courseId, {bool fromCache = false}) {
    return repository.getCourseDetails(courseId, fromCache: fromCache);
  }
}

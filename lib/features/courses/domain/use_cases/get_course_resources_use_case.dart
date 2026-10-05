import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class GetCourseResourcesUseCase {
  final CoursesRepository repository;

  GetCourseResourcesUseCase(this.repository);

  Future<Either<Failure, List<CourseResource>>> call(int courseId, {bool fromCache = false}) {
    return repository.getCourseResources(courseId, fromCache: fromCache);
  }
}

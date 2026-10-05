import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class GetCourseAssignmentsUseCase {
  final CoursesRepository repository;

  GetCourseAssignmentsUseCase(this.repository);

  Future<Either<Failure, List<CourseAssignment>>> call(int courseId, {bool fromCache = false}) {
    return repository.getCourseAssignments(courseId, fromCache: fromCache);
  }
}

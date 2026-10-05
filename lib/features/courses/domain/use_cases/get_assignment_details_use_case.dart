import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class GetAssignmentDetailsUseCase {
  final CoursesRepository repository;

  GetAssignmentDetailsUseCase(this.repository);

  Future<Either<Failure, CourseAssignment>> call(int assignmentId) {
    return repository.getAssignmentDetails(assignmentId);
  }
}

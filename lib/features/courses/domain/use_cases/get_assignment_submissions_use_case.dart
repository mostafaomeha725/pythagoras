import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/assignment_submission.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class GetAssignmentSubmissionsUseCase {
  final CoursesRepository repository;

  GetAssignmentSubmissionsUseCase(this.repository);

  Future<Either<Failure, List<AssignmentSubmission>>> call(int assignmentId, {bool fromCache = false}) {
    return repository.getAssignmentSubmissions(assignmentId, fromCache: fromCache);
  }
}

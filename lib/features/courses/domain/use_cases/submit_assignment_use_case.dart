import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/assignment_submission.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class SubmitAssignmentUseCase {
  final CoursesRepository repository;

  SubmitAssignmentUseCase(this.repository);

  Future<Either<Failure, AssignmentSubmission>> call({
    required int assignmentId,
    String? notes,
    String? filePath,
    String? fileName,
  }) {
    return repository.submitAssignment(
      assignmentId: assignmentId,
      notes: notes,
      filePath: filePath,
      fileName: fileName,
    );
  }
}

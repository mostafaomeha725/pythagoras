import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/enrollment_result.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class EnrollChapterUseCase {
  final CoursesRepository repository;

  EnrollChapterUseCase(this.repository);

  Future<Either<Failure, EnrollmentResult>> call(int chapterId) {
    return repository.enrollChapter(chapterId);
  }
}

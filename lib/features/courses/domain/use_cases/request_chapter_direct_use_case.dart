import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

/// iOS-only use case: sends a direct chapter enrollment request
/// to `POST /api/request/chapter/direct` and returns the server message.
class RequestChapterDirectUseCase {
  final CoursesRepository repository;

  RequestChapterDirectUseCase(this.repository);

  Future<Either<Failure, String>> call(int chapterId) {
    return repository.requestChapterDirect(chapterId);
  }
}

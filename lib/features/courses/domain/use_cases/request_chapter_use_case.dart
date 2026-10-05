import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class RequestChapterUseCase {
  final CoursesRepository repository;

  RequestChapterUseCase(this.repository);

  Future<Either<Failure, String>> call(int chapterId) {
    return repository.requestChapter(chapterId);
  }
}

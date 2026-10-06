import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class DownloadResourceUseCase {
  final CoursesRepository repository;

  DownloadResourceUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int resourceId,
    required String title,
    required String fileName,
  }) async {
    return await repository.downloadResourceNative(
      resourceId: resourceId,
      title: title,
      fileName: fileName,
    );
  }
}

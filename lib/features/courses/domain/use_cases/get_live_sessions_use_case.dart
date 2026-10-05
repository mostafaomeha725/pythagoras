import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/live_session.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class GetLiveSessionsUseCase {
  final CoursesRepository repository;

  GetLiveSessionsUseCase(this.repository);

  Future<Either<Failure, List<LiveSession>>> call(int courseId, {bool fromCache = false}) async {
    return await repository.getLiveSessions(courseId, fromCache: fromCache);
  }
}

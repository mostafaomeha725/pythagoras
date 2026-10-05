import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_result.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class GetQuizResultUseCase {
  final CoursesRepository repository;

  GetQuizResultUseCase(this.repository);

  Future<Either<Failure, QuizResult>> call(int quizId, {bool fromCache = false}) async {
    return await repository.getQuizResult(quizId, fromCache: fromCache);
  }
}

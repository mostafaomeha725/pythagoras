import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_attempt.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class StartQuizAttemptUseCase {
  final CoursesRepository repository;

  StartQuizAttemptUseCase(this.repository);

  Future<Either<Failure, QuizAttempt>> call(int quizId) async {
    return await repository.startQuizAttempt(quizId);
  }
}

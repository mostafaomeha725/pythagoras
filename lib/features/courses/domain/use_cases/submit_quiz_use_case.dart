import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_result.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class SubmitQuizUseCase {
  final CoursesRepository repository;

  SubmitQuizUseCase(this.repository);

  Future<Either<Failure, QuizResult>> call({
    required int quizId,
    required List<Map<String, dynamic>> answers,
  }) async {
    return await repository.submitQuiz(quizId: quizId, answers: answers);
  }
}

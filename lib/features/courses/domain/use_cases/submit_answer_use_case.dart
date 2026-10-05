import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/answer_submitted.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class SubmitAnswerUseCase {
  final CoursesRepository repository;

  SubmitAnswerUseCase(this.repository);

  Future<Either<Failure, AnswerSubmitted>> call({
    required int quizId,
    required int quizAttemptId,
    required int questionId,
    int? optionId,
    dynamic selectedAnswer,
  }) async {
    return await repository.submitAnswer(
      quizId: quizId,
      quizAttemptId: quizAttemptId,
      questionId: questionId,
      optionId: optionId,
      selectedAnswer: selectedAnswer,
    );
  }
}

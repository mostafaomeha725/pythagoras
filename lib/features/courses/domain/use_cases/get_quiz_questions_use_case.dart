import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_question.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class GetQuizQuestionsUseCase {
  final CoursesRepository repository;

  GetQuizQuestionsUseCase(this.repository);

  Future<Either<Failure, List<QuizQuestion>>> call(int quizId) async {
    return await repository.getQuizQuestions(quizId);
  }
}

import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class GetQuizDetailsUseCase {
  final CoursesRepository repository;

  GetQuizDetailsUseCase(this.repository);

  Future<Either<Failure, CourseQuiz>> call(int quizId) async {
    return await repository.getQuizDetails(quizId);
  }
}

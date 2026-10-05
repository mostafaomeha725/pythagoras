import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class GetClassesUseCase {
  final CoursesRepository repository;

  GetClassesUseCase(this.repository);

  Future<Either<Failure, List<StudentClass>>> call({bool fromCache = false}) {
    return repository.getClasses(fromCache: fromCache);
  }
}

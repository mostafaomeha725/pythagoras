import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/course.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class GetCoursesUseCase {
  final CoursesRepository repository;

  GetCoursesUseCase(this.repository);

  Future<Either<Failure, List<Course>>> call({int? classId, int? semester, bool fromCache = false}) async {
    return await repository.getCourses(classId: classId, semester: semester, fromCache: fromCache);
  }
}

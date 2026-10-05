import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class GetCourseCurriculumUseCase {
  final CoursesRepository repository;

  GetCourseCurriculumUseCase(this.repository);

  Future<Either<Failure, CourseDetail>> call(int courseId, {bool fromCache = false}) {
    return repository.getCourseCurriculum(courseId, fromCache: fromCache);
  }
}

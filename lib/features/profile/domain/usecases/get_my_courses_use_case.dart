import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/profile/domain/entities/my_course_enrollment.dart';
import 'package:pythagoras/features/profile/domain/repositories/profile_repository.dart';

class GetMyCoursesUseCase {
  final ProfileRepository repository;

  GetMyCoursesUseCase(this.repository);

  Future<Either<Failure, List<MyCourseEnrollment>>> call({bool fromCache = false}) {
    return repository.getMyCourses(fromCache: fromCache);
  }
}

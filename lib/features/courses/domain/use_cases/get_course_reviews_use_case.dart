import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/course_reviews_data.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class GetCourseReviewsUseCase {
  final CoursesRepository repository;

  GetCourseReviewsUseCase(this.repository);

  Future<Either<Failure, CourseReviewsData>> call(int courseId, {bool fromCache = false}) async {
    return await repository.getCourseReviews(courseId, fromCache: fromCache);
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/domain/entities/course_review.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

class AddCourseReviewUseCase {
  final CoursesRepository repository;

  AddCourseReviewUseCase(this.repository);

  Future<Either<Failure, CourseReview>> call(AddCourseReviewParams params) async {
    return await repository.addCourseReview(
      courseId: params.courseId,
      rating: params.rating,
      comment: params.comment,
    );
  }
}

class AddCourseReviewParams extends Equatable {
  final int courseId;
  final double rating;
  final String comment;

  const AddCourseReviewParams({
    required this.courseId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [courseId, rating, comment];
}

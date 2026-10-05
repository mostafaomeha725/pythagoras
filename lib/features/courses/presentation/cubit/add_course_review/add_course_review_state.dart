import 'package:equatable/equatable.dart';
import 'package:pythagoras/features/courses/domain/entities/course_review.dart';

abstract class AddCourseReviewState extends Equatable {
  const AddCourseReviewState();

  @override
  List<Object?> get props => [];
}

class AddCourseReviewInitial extends AddCourseReviewState {}

class AddCourseReviewLoading extends AddCourseReviewState {}

class AddCourseReviewSuccess extends AddCourseReviewState {
  final CourseReview review;

  const AddCourseReviewSuccess(this.review);

  @override
  List<Object?> get props => [review];
}

class AddCourseReviewError extends AddCourseReviewState {
  final String message;

  const AddCourseReviewError(this.message);

  @override
  List<Object?> get props => [message];
}

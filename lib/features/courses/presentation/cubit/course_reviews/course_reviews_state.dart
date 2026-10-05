import 'package:equatable/equatable.dart';
import 'package:pythagoras/features/courses/domain/entities/course_reviews_data.dart';

abstract class CourseReviewsState extends Equatable {
  const CourseReviewsState();

  @override
  List<Object?> get props => [];
}

class CourseReviewsInitial extends CourseReviewsState {}

class CourseReviewsLoading extends CourseReviewsState {}

class CourseReviewsLoaded extends CourseReviewsState {
  final CourseReviewsData reviewsData;

  const CourseReviewsLoaded(this.reviewsData);

  @override
  List<Object?> get props => [reviewsData];
}

class CourseReviewsError extends CourseReviewsState {
  final String message;

  const CourseReviewsError(this.message);

  @override
  List<Object?> get props => [message];
}

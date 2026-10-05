import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';

abstract class CourseDetailsState {}

class CourseDetailsInitial extends CourseDetailsState {}

class CourseDetailsLoading extends CourseDetailsState {}

class CourseDetailsLoaded extends CourseDetailsState {
  final CourseDetail courseDetail;

  CourseDetailsLoaded({required this.courseDetail});
}

class CourseDetailsError extends CourseDetailsState {
  final String message;

  CourseDetailsError(this.message);
}

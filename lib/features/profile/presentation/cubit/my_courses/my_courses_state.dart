import 'package:pythagoras/features/profile/domain/entities/my_course_enrollment.dart';

abstract class MyCoursesState {}

class MyCoursesInitial extends MyCoursesState {}

class MyCoursesLoading extends MyCoursesState {}

class MyCoursesLoaded extends MyCoursesState {
  final List<MyCourseEnrollment> enrollments;
  MyCoursesLoaded(this.enrollments);
}

class MyCoursesError extends MyCoursesState {
  final String message;
  MyCoursesError(this.message);
}

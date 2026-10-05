import 'package:pythagoras/features/courses/domain/entities/course.dart';

abstract class CoursesListState {}

class CoursesListInitial extends CoursesListState {}

class CoursesListLoading extends CoursesListState {}

class CoursesListLoaded extends CoursesListState {
  final List<Course> courses;
  CoursesListLoaded(this.courses);
}

class CoursesListError extends CoursesListState {
  final String message;
  CoursesListError(this.message);
}

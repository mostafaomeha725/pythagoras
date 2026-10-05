import 'package:equatable/equatable.dart';
import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';

abstract class CourseResourcesState extends Equatable {
  const CourseResourcesState();

  @override
  List<Object?> get props => [];
}

class CourseResourcesInitial extends CourseResourcesState {}

class CourseResourcesLoading extends CourseResourcesState {}

class CourseResourcesLoaded extends CourseResourcesState {
  final List<CourseResource> resources;

  const CourseResourcesLoaded(this.resources);

  @override
  List<Object?> get props => [resources];
}

class CourseResourcesError extends CourseResourcesState {
  final String message;

  const CourseResourcesError(this.message);

  @override
  List<Object?> get props => [message];
}

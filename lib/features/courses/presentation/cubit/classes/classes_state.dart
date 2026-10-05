import 'package:equatable/equatable.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';

abstract class ClassesState extends Equatable {
  const ClassesState();

  @override
  List<Object?> get props => [];
}

class ClassesInitial extends ClassesState {}

class ClassesLoading extends ClassesState {}

class ClassesLoaded extends ClassesState {
  final List<StudentClass> classes;
  final StudentClass? selectedClass;

  const ClassesLoaded({required this.classes, this.selectedClass});

  @override
  List<Object?> get props => [classes, selectedClass];
}

class ClassesError extends ClassesState {
  final String message;

  const ClassesError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

abstract class CompleteLessonState {}

class CompleteLessonInitial extends CompleteLessonState {}

class CompleteLessonLoading extends CompleteLessonState {
  final int lessonId;
  CompleteLessonLoading(this.lessonId);
}

class CompleteLessonSuccess extends CompleteLessonState {
  final int lessonId;
  final String message;
  CompleteLessonSuccess({required this.lessonId, required this.message});
}

class CompleteLessonError extends CompleteLessonState {
  final int lessonId;
  final String message;
  CompleteLessonError({required this.lessonId, required this.message});
}

class CompleteLessonCubit extends Cubit<CompleteLessonState> {
  final CoursesRepository repository;

  CompleteLessonCubit({required this.repository}) : super(CompleteLessonInitial());

  Future<void> completeLesson(int lessonId) async {
    emit(CompleteLessonLoading(lessonId));
    final result = await repository.completeLesson(lessonId);
    result.fold(
      (failure) {
        if (!isClosed) emit(CompleteLessonError(lessonId: lessonId, message: failure.message));
      },
      (message) {
        if (!isClosed) emit(CompleteLessonSuccess(lessonId: lessonId, message: message));
      },
    );
  }
}

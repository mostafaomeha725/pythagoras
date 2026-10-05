import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_chapter_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_course_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_state.dart';

class RequestEnrollmentCubit extends Cubit<RequestEnrollmentState> {
  final RequestCourseUseCase requestCourseUseCase;
  final RequestChapterUseCase requestChapterUseCase;

  RequestEnrollmentCubit(this.requestCourseUseCase, this.requestChapterUseCase)
      : super(RequestEnrollmentInitial());

  Future<void> requestCourse(int courseId) async {
    emit(RequestEnrollmentLoading());
    final result = await requestCourseUseCase(courseId);
    result.fold(
      (failure) => emit(RequestEnrollmentError(failure.message)),
      (whatsappUrl) => emit(RequestEnrollmentSuccess(whatsappUrl)),
    );
  }

  Future<void> requestChapter(int chapterId) async {
    emit(RequestEnrollmentLoading());
    final result = await requestChapterUseCase(chapterId);
    result.fold(
      (failure) => emit(RequestEnrollmentError(failure.message)),
      (whatsappUrl) => emit(RequestEnrollmentSuccess(whatsappUrl)),
    );
  }
}

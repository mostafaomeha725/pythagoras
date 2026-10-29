import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_chapter_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_course_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_state.dart';

class RequestEnrollmentCubit extends Cubit<RequestEnrollmentState> {
  final RequestCourseUseCase requestCourseUseCase;
  final RequestChapterUseCase requestChapterUseCase;
  final bool Function() _isCourseLessonRequestsEnabled;

  RequestEnrollmentCubit(
    this.requestCourseUseCase,
    this.requestChapterUseCase, {
    bool Function()? isCourseLessonRequestsEnabled,
  }) : _isCourseLessonRequestsEnabled =
           isCourseLessonRequestsEnabled ?? (() => true),
       super(RequestEnrollmentInitial());

  Future<void> requestCourse(int courseId, {String? courseTitle}) async {
    if (!_isCourseLessonRequestsEnabled()) return;
    emit(RequestEnrollmentLoading());
    final result = await requestCourseUseCase(courseId);
    result.fold(
      (failure) => emit(RequestEnrollmentError(failure.message)),
      (whatsappUrl) => emit(
        RequestEnrollmentSuccess(
          whatsappUrl,
          courseTitle: courseTitle,
          isChapter: false,
        ),
      ),
    );
  }

  Future<void> requestChapter(int chapterId, {String? chapterTitle}) async {
    if (!_isCourseLessonRequestsEnabled()) return;
    emit(RequestEnrollmentLoading());
    final result = await requestChapterUseCase(chapterId);
    result.fold(
      (failure) => emit(RequestEnrollmentError(failure.message)),
      (whatsappUrl) => emit(
        RequestEnrollmentSuccess(
          whatsappUrl,
          chapterTitle: chapterTitle,
          isChapter: true,
        ),
      ),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_chapter_direct_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_course_direct_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/direct_request/direct_request_state.dart';

/// iOS-only cubit that handles direct course and chapter enrollment requests
/// via `POST /api/request/course/direct` and `POST /api/request/chapter/direct`.
///
/// On Android these methods are never called — the existing
/// [RequestEnrollmentCubit] (WhatsApp flow) continues to handle all requests.
class DirectRequestCubit extends Cubit<DirectRequestState> {
  final RequestCourseDirectUseCase requestCourseDirectUseCase;
  final RequestChapterDirectUseCase requestChapterDirectUseCase;
  final bool Function() _isCourseLessonRequestsEnabled;

  DirectRequestCubit({
    required this.requestCourseDirectUseCase,
    required this.requestChapterDirectUseCase,
    bool Function()? isCourseLessonRequestsEnabled,
  }) : _isCourseLessonRequestsEnabled =
           isCourseLessonRequestsEnabled ?? (() => true),
       super(DirectRequestInitial());

  /// Sends a direct course enrollment request for [courseId].
  /// Ignored when a request is already in-flight.
  Future<void> requestCourse(int courseId) async {
    if (!_isCourseLessonRequestsEnabled() || state is DirectRequestLoading) {
      return;
    }
    emit(DirectRequestLoading());
    final result = await requestCourseDirectUseCase(courseId);
    result.fold(
      (failure) => emit(DirectRequestError(failure.message)),
      (message) => emit(DirectRequestSuccess(message)),
    );
  }

  /// Sends a direct chapter enrollment request for [chapterId].
  /// Ignored when a request is already in-flight.
  Future<void> requestChapter(int chapterId) async {
    if (!_isCourseLessonRequestsEnabled() || state is DirectRequestLoading) {
      return;
    }
    emit(DirectRequestLoading());
    final result = await requestChapterDirectUseCase(chapterId);
    result.fold(
      (failure) => emit(DirectRequestError(failure.message)),
      (message) => emit(DirectRequestSuccess(message)),
    );
  }
}

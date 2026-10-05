import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_live_sessions_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_live_sessions/course_live_sessions_state.dart';

class CourseLiveSessionsCubit extends Cubit<CourseLiveSessionsState> {
  final GetLiveSessionsUseCase getLiveSessionsUseCase;

  CourseLiveSessionsCubit({required this.getLiveSessionsUseCase})
      : super(CourseLiveSessionsInitial());

  bool _isFetchingRemote = false;

  Future<void> getSessions(int courseId) async {
    // 1. Try Cache
    final cacheResult = await getLiveSessionsUseCase(courseId, fromCache: true);
    
    if (isClosed) return;

    bool hasCache = false;
    cacheResult.fold(
      (failure) {
        if (state is! CourseLiveSessionsLoaded) {
          emit(CourseLiveSessionsLoading());
        }
      },
      (sessions) {
        hasCache = true;
        if (!isClosed) emit(CourseLiveSessionsLoaded(sessions));
      },
    );

    if (_isFetchingRemote) return;
    _isFetchingRemote = true;

    // 2. Fetch Remote (Background revalidate)
    final result = await getLiveSessionsUseCase(courseId, fromCache: false);
    
    if (isClosed) return;
    _isFetchingRemote = false;

    result.fold(
      (failure) {
        if (!hasCache && state is! CourseLiveSessionsLoaded) {
          if (!isClosed) emit(CourseLiveSessionsError(failure.message));
        }
      },
      (sessions) {
        if (!isClosed) emit(CourseLiveSessionsLoaded(sessions));
      },
    );
  }
}

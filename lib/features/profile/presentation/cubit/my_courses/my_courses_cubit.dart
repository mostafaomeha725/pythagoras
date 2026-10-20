import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/profile/domain/usecases/get_my_courses_use_case.dart';
import 'my_courses_state.dart';

class MyCoursesCubit extends Cubit<MyCoursesState> {
  final GetMyCoursesUseCase getMyCoursesUseCase;

  MyCoursesCubit(this.getMyCoursesUseCase) : super(MyCoursesInitial());

  bool _isFetchingRemote = false;

  Future<void> fetchMyCourses() async {
    // 1. Try Cache
    final cacheResult = await getMyCoursesUseCase(fromCache: true);

    if (isClosed) return;

    bool hasCache = false;
    cacheResult.fold(
      (failure) {
        if (state is! MyCoursesLoaded) {
          emit(MyCoursesLoading());
        }
      },
      (enrollments) {
        hasCache = true;
        if (!isClosed) emit(MyCoursesLoaded(enrollments));
      },
    );

    if (_isFetchingRemote) return;
    _isFetchingRemote = true;

    // 2. Fetch Remote
    final result = await getMyCoursesUseCase(fromCache: false);

    if (isClosed) return;
    _isFetchingRemote = false;

    result.fold(
      (failure) {
        if (!hasCache && state is! MyCoursesLoaded) {
          if (!isClosed) emit(MyCoursesError(failure.message));
        }
      },
      (enrollments) {
        if (!isClosed) emit(MyCoursesLoaded(enrollments));
      },
    );
  }
}

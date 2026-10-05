import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_course_resources_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_resources/course_resources_state.dart';

class CourseResourcesCubit extends Cubit<CourseResourcesState> {
  final GetCourseResourcesUseCase getCourseResourcesUseCase;

  CourseResourcesCubit({
    required this.getCourseResourcesUseCase,
  }) : super(CourseResourcesInitial());

  bool _isFetchingRemote = false;

  Future<void> getResources(int courseId) async {
    // 1. Try Cache
    final cacheResult = await getCourseResourcesUseCase(courseId, fromCache: true);
    
    if (isClosed) return;

    bool hasCache = false;
    cacheResult.fold(
      (failure) {
        if (state is! CourseResourcesLoaded) {
          emit(CourseResourcesLoading());
        }
      },
      (resources) {
        hasCache = true;
        if (!isClosed) emit(CourseResourcesLoaded(resources));
      },
    );

    if (_isFetchingRemote) return;
    _isFetchingRemote = true;

    // 2. Fetch Remote (Background revalidate)
    final result = await getCourseResourcesUseCase(courseId, fromCache: false);
    
    if (isClosed) return;
    _isFetchingRemote = false;

    result.fold(
      (failure) {
        if (!hasCache && state is! CourseResourcesLoaded) {
          if (!isClosed) emit(CourseResourcesError(failure.message));
        }
      },
      (resources) {
        if (!isClosed) emit(CourseResourcesLoaded(resources));
      },
    );
  }
}

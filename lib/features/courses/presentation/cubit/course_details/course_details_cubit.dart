import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_course_curriculum_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_state.dart';

class CourseDetailsCubit extends Cubit<CourseDetailsState> {
  final GetCourseCurriculumUseCase getCourseCurriculumUseCase;

  CourseDetailsCubit(this.getCourseCurriculumUseCase)
    : super(CourseDetailsInitial());

  Future<void> fetchCourseDetails(int courseId) async {
    if (isClosed) return;
    emit(CourseDetailsLoading());

    try {
      // 1. Try Cache (SWR Pattern)
      final cacheResult = await getCourseCurriculumUseCase(
        courseId,
        fromCache: true,
      );

      bool hasCache = false;
      cacheResult.fold((failure) {}, (courseDetail) {
        if (isClosed) return;
        hasCache = true;
        emit(CourseDetailsLoaded(courseDetail: courseDetail));
      });

      // 2. Fetch Remote (Background revalidate)
      // Using curriculum API to get both details and videos
      final result = await getCourseCurriculumUseCase(
        courseId,
        fromCache: false,
      );

      result.fold(
        (failure) {
          // Only show error if we don't have cache to display
          if (!hasCache && !isClosed) {
            emit(CourseDetailsError(failure.message));
          }
        },
        (courseDetail) {
          if (!isClosed) {
            emit(CourseDetailsLoaded(courseDetail: courseDetail));
          }
        },
      );
    } catch (error) {
      if (!isClosed && state is! CourseDetailsLoaded) {
        emit(CourseDetailsError(error.toString()));
      }
    }
  }
}

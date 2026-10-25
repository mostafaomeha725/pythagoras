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
      final result = await getCourseCurriculumUseCase(
        courseId,
        fromCache: false,
      );

      result.fold(
        (failure) {
          if (!isClosed) {
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
      if (!isClosed) {
        emit(CourseDetailsError(error.toString()));
      }
    }
  }
}

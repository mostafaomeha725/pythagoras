import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_course_reviews_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_reviews/course_reviews_state.dart';

class CourseReviewsCubit extends Cubit<CourseReviewsState> {
  final GetCourseReviewsUseCase getCourseReviewsUseCase;

  CourseReviewsCubit(this.getCourseReviewsUseCase) : super(CourseReviewsInitial());

  Future<void> fetchCourseReviews(int courseId) async {
    // 1. Try Cache (SWR Pattern)
    final cacheResult = await getCourseReviewsUseCase(courseId, fromCache: true);

    bool hasCache = false;
    cacheResult.fold(
      (failure) {
        if (!isClosed) emit(CourseReviewsLoading());
      },
      (reviewsData) {
        hasCache = true;
        if (!isClosed) emit(CourseReviewsLoaded(reviewsData));
      },
    );

    // 2. Fetch Remote (Background revalidate)
    final result = await getCourseReviewsUseCase(courseId, fromCache: false);

    result.fold(
      (failure) {
        if (!hasCache && state is! CourseReviewsLoaded) {
          if (!isClosed) emit(CourseReviewsError(failure.message));
        }
      },
      (reviewsData) {
        if (!isClosed) emit(CourseReviewsLoaded(reviewsData));
      },
    );
  }
}

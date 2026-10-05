import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/use_cases/add_course_review_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/add_course_review/add_course_review_state.dart';

class AddCourseReviewCubit extends Cubit<AddCourseReviewState> {
  final AddCourseReviewUseCase addCourseReviewUseCase;

  AddCourseReviewCubit(this.addCourseReviewUseCase) : super(AddCourseReviewInitial());

  Future<void> addReview({
    required int courseId,
    required double rating,
    required String comment,
  }) async {
    emit(AddCourseReviewLoading());
    final result = await addCourseReviewUseCase(
      AddCourseReviewParams(courseId: courseId, rating: rating, comment: comment),
    );
    result.fold(
      (failure) => emit(AddCourseReviewError(failure.message)),
      (review) => emit(AddCourseReviewSuccess(review)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/auth_guard.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/cubit/add_course_review/add_course_review_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/add_course_review/add_course_review_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_reviews/course_reviews_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_add_input.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_add_stars.dart';

/// Form card for submitting a new course review on Tablet Landscape.
class CourseReviewsTabletAddCard extends StatefulWidget {
  final int courseId;

  const CourseReviewsTabletAddCard({super.key, required this.courseId});

  @override
  State<CourseReviewsTabletAddCard> createState() =>
      _CourseReviewsTabletAddCardState();
}

class _CourseReviewsTabletAddCardState
    extends State<CourseReviewsTabletAddCard> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  bool _showRatingError = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_rating == 0) {
      setState(() => _showRatingError = true);
      return;
    }
    context.read<AddCourseReviewCubit>().addReview(
      courseId: widget.courseId,
      rating: _rating.toDouble(),
      comment: _commentController.text.trim(),
    );
  }

  void _onStateChanged(BuildContext context, AddCourseReviewState state) {
    if (state is AddCourseReviewLoading) {
      EasyLoading.show(status: 'جاري إضافة التقييم...');
    } else if (state is AddCourseReviewSuccess) {
      EasyLoading.showSuccess('تمت إضافة تقييمك بنجاح');
      _commentController.clear();
      setState(() {
        _rating = 0;
        _showRatingError = false;
      });
      context.read<CourseReviewsCubit>().fetchCourseReviews(widget.courseId);
    } else if (state is AddCourseReviewError) {
      EasyLoading.showError(state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCourseReviewCubit, AddCourseReviewState>(
      listener: _onStateChanged,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppLightColors.primary.withValues(alpha: 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText(
              'أضف تقييمك',
              style: font16w700.copyWith(
                color: const Color(0xFF1E1E2D),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            AppText(
              'شارك تجربتك بصراحة لمساعدة طلاب آخرين',
              style: font12w400.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 12),
            AppText(
              'كيف تقيم الدورة؟',
              style: font14w700.copyWith(
                color: const Color(0xFF1E1E2D),
                fontSize: 13,
              ),
              alignment: AlignmentDirectional.center,
            ),
            const SizedBox(height: 8),
            CourseReviewsTabletAddStars(
              rating: _rating,
              showRatingError: _showRatingError,
              onRatingChanged: (val) => setState(() {
                _rating = val;
                _showRatingError = false;
              }),
            ),
            const SizedBox(height: 12),
            CourseReviewsTabletAddInput(
              controller: _commentController,
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF2F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.volunteer_activism_outlined,
                    color: Color(0xFFBE185D),
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText(
                      'رأيك يساعدنا على تحسين تجربة التعلّم وتطوير محتوى الدورة.',
                      style: font10w500.copyWith(
                        color: const Color(0xFFBE185D),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
              text: 'إرسال التقييم',
              onPressed: () =>
                  AuthGuard.checkAuthAndExecute(context, _submitReview),
              radius: 10,
              color: AppLightColors.primary,
              textColor: Colors.white,
              textWeight: FontWeight.w700,
              textSize: 13.5,
            ),
          ],
        ),
      ),
    );
  }
}

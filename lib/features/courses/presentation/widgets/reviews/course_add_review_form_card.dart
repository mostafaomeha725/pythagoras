import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/features/courses/presentation/cubit/add_course_review/add_course_review_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/add_course_review/add_course_review_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_reviews/course_reviews_cubit.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_add_review_stars.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_add_review_input.dart';

import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_add_review_header.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_add_review_helper_banner.dart';

class CourseAddReviewFormCard extends StatefulWidget {
  final int courseId;
  const CourseAddReviewFormCard({super.key, required this.courseId});

  @override
  State<CourseAddReviewFormCard> createState() =>
      _CourseAddReviewFormCardState();
}

class _CourseAddReviewFormCardState extends State<CourseAddReviewFormCard> {
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
      setState(() {
        _showRatingError = true;
      });
      return;
    }

    final comment = _commentController.text.trim();

    context.read<AddCourseReviewCubit>().addReview(
      courseId: widget.courseId,
      rating: _rating.toDouble(),
      comment: comment,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCourseReviewCubit, AddCourseReviewState>(
      listener: (context, state) {
        if (state is AddCourseReviewLoading) {
          EasyLoading.show(status: 'جاري إضافة التقييم...');
        } else if (state is AddCourseReviewSuccess) {
          EasyLoading.showSuccess('تمت إضافة تقييمك بنجاح');
          _commentController.clear();
          setState(() {
            _rating = 0;
            _showRatingError = false;
          });
          // Refresh the reviews list
          context.read<CourseReviewsCubit>().fetchCourseReviews(
            widget.courseId,
          );
        } else if (state is AddCourseReviewError) {
          EasyLoading.showError(state.message);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const CourseAddReviewHeader(),
          SizedBox(height: 16.h),

          // Card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppLightColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                AppText(
                  'كيف تقيم الدورة؟',
                  style: font14w700.copyWith(color: const Color(0xFF1E1E2D)),
                ),
                SizedBox(height: 16.h),

                CourseAddReviewStars(
                  rating: _rating,
                  showRatingError: _showRatingError,
                  onRatingChanged: (newRating) {
                    setState(() {
                      _rating = newRating;
                      _showRatingError = false;
                    });
                  },
                ),

                CourseAddReviewInput(
                  controller: _commentController,
                  onChanged: (val) => setState(() {}),
                ),
                SizedBox(height: 16.h),

                // Helper Banner
                const CourseAddReviewHelperBanner(),
                SizedBox(height: 20.h),

                // Submit Button
                AppButton(
                  text: 'إرسال التقييم',
                  onPressed: _submitReview,
                  radius: 12.r,
                  color: AppLightColors.primary,
                  textColor: Colors.white,
                  textWeight: FontWeight.w700,
                  textSize: 14.sp,
                ),
                SizedBox(height: 12.h),

                // Footer text
                AppText(
                  'سيظهر تقييمك باسمك الأول فقط بعد المراجعة',
                  style: font10w400.copyWith(color: const Color(0xFF9CA3AF)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

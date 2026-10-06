import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/features/courses/domain/entities/course_review.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_reviews/course_reviews_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_reviews/course_reviews_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_review_header_info.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_overall_rating_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_filter_header.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_review_item_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_add_review_form_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_shimmer.dart';

class CourseReviewsScreenBody extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const CourseReviewsScreenBody({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<CourseReviewsScreenBody> createState() =>
      _CourseReviewsScreenBodyState();
}

class _CourseReviewsScreenBodyState extends State<CourseReviewsScreenBody> {
  String _sortType = 'latest';

  String _formatDate(DateTime date) {
    return DateFormat('hh:mm a, dd MMMM yyyy', 'ar').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        children: [
          CourseReviewHeaderInfo(title: widget.courseTitle),
          SizedBox(height: 24.h),
          CourseAddReviewFormCard(courseId: widget.courseId),
          SizedBox(height: 32.h),
          BlocBuilder<CourseReviewsCubit, CourseReviewsState>(
            builder: (context, state) {
              if (state is CourseReviewsLoading) {
                return const CourseReviewsShimmer();
              } else if (state is CourseReviewsError) {
                return Center(child: Text(state.message));
              } else if (state is CourseReviewsLoaded) {
                final data = state.reviewsData;

                // Sort logic
                List<CourseReview> displayedReviews = List.from(data.reviews);
                if (_sortType == 'latest') {
                  displayedReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                } else {
                  displayedReviews.sort((a, b) => b.rating.compareTo(a.rating));
                }

                return Column(
                  children: [
                    CourseOverallRatingCard(data: data),
                    SizedBox(height: 32.h),
                CourseReviewsFilterHeader(
                  totalReviews: data.totalReviews,
                  currentSort: _sortType,
                  onSortChanged: (type) {
                    setState(() {
                      _sortType = type;
                    });
                  },
                ),
                SizedBox(height: 24.h),

                // Actual data
                if (displayedReviews.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(32.h),
                    child: Text(
                      'لا توجد تقييمات بعد.',
                      style: font14w500.copyWith(color: Colors.grey),
                    ),
                  )
                else
                  ...displayedReviews.map(
                    (review) => CourseReviewItemCard(
                      name: review.userName,
                      date: _formatDate(review.createdAt),
                      rating: review.rating,
                      reviewText: review.comment,
                      helpfulCount:
                          0, // Mock helpful count since it's not in the API
                      imageUrl: review.userAvatarUrl ?? '',
                    ),
                  ),

                SizedBox(height: 40.h),
              ],
            );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

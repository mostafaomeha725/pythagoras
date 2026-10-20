import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';
import 'package:pythagoras/features/courses/domain/entities/course_review.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_reviews/course_reviews_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_reviews/course_reviews_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_empty_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_filter_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_review_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_shimmer.dart';

/// Reviews list with sorting and filtering for Tablet.
class CourseReviewsTabletList extends StatefulWidget {
  final int courseId;

  const CourseReviewsTabletList({super.key, required this.courseId});

  @override
  State<CourseReviewsTabletList> createState() =>
      _CourseReviewsTabletListState();
}

class _CourseReviewsTabletListState extends State<CourseReviewsTabletList> {
  String _sortType = 'latest';

  String _formatDate(DateTime date) {
    return DateFormat('hh:mm a, dd MMMM yyyy', 'ar').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseReviewsCubit, CourseReviewsState>(
      builder: (context, state) {
        if (state is CourseReviewsLoading) {
          return const CourseReviewsTabletListShimmer();
        }
        if (state is CourseReviewsError) {
          return NoInternetWidget(
            message: state.message,
            onRetry: () => context
                .read<CourseReviewsCubit>()
                .fetchCourseReviews(widget.courseId),
          );
        }
        if (state is CourseReviewsLoaded) {
          final displayedReviews = List<CourseReview>.from(
            state.reviewsData.reviews,
          );
          if (_sortType == 'latest') {
            displayedReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          } else {
            displayedReviews.sort((a, b) => b.rating.compareTo(a.rating));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CourseReviewsTabletFilterBar(
                totalReviews: state.reviewsData.totalReviews,
                currentSort: _sortType,
                onSortChanged: (type) {
                  setState(() => _sortType = type);
                },
              ),
              const SizedBox(height: 12),
              if (displayedReviews.isEmpty)
                const CourseReviewsTabletEmptyState()
              else
                ...displayedReviews.map(
                  (review) => CourseReviewsTabletReviewCard(
                    name: review.userName,
                    date: _formatDate(review.createdAt),
                    rating: review.rating,
                    reviewText: review.comment,
                    imageUrl: review.userAvatarUrl ?? '',
                  ),
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

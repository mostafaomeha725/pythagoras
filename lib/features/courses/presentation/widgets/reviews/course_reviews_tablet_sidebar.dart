import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_reviews/course_reviews_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_reviews/course_reviews_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_add_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_rating_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_shimmer.dart';

/// Right Sidebar on Tablet Landscape containing course context, rating summary, and add review form.
class CourseReviewsTabletSidebar extends StatelessWidget {
  final int courseId;
  final String courseTitle;

  const CourseReviewsTabletSidebar({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Course Context Banner Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEEFA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: AppLightColors.primary,
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      courseTitle,
                      style: font16w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                        fontSize: 13.5,
                        height: 1.3,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      'تجارب حقيقية من طلاب الدورة',
                      style: font12w400.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEEFA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AppText(
                  'الدورة',
                  style: font12w700.copyWith(
                    color: AppLightColors.primary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Overall Rating Card (Reactive to Cubit)
        BlocBuilder<CourseReviewsCubit, CourseReviewsState>(
          builder: (context, state) {
            if (state is CourseReviewsLoading) {
              return const CourseReviewsTabletRatingShimmer();
            }
            if (state is CourseReviewsLoaded) {
              return CourseReviewsTabletRatingCard(data: state.reviewsData);
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 12),

        // Add Review Form Card (Always Mounted)
        CourseReviewsTabletAddCard(courseId: courseId),
      ],
    );
  }
}

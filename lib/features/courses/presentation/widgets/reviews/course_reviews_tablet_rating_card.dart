import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_reviews_data.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_distribution_row.dart';

/// Overall rating and distribution card for Tablet Landscape.
class CourseReviewsTabletRatingCard extends StatelessWidget {
  final CourseReviewsData data;

  const CourseReviewsTabletRatingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppLightColors.primary.withValues(alpha: 0.18),
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
      child: Row(
        children: [
          // Rating Summary
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                data.averageRating.toStringAsFixed(1),
                style: font22w700.copyWith(
                  fontSize: 36,
                  height: 1.1,
                  color: const Color(0xFF1E1E2D),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final isFilled = index < data.averageRating.floor();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFFBBF24),
                      size: 15,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
              AppText(
                '${data.totalReviews} تقييم',
                style: font12w400.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // Vertical Divider
          Container(
            height: 90,
            width: 1,
            color: const Color(0xFFF1F5F9),
            margin: const EdgeInsets.symmetric(horizontal: 18),
          ),

          // Distribution Bars using CourseReviewsTabletDistributionRow
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [5, 4, 3, 2, 1]
                  .map(
                    (s) => CourseReviewsTabletDistributionRow(
                      stars: s,
                      percent: data.ratingsDistribution[s] ?? 0,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

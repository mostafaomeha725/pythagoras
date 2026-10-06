import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/features/courses/domain/entities/course_reviews_data.dart';

import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_progress_bar.dart';

class CourseOverallRatingCard extends StatelessWidget {
  final CourseReviewsData data;
  const CourseOverallRatingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppLightColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Rating Info (Right side in RTL)
              Column(
                children: [
                  Text(
                    data.averageRating.toStringAsFixed(1),
                    style: font22w700.copyWith(
                      fontSize: 48.sp,
                      height: 1.1,
                      color: const Color(0xFF1E1E2D),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Icon(
                          index < data.averageRating.floor()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFFBBF24),
                          size: 16.sp,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${data.totalReviews} تقييم',
                    style: font12w400.copyWith(color: const Color(0xFF6B7280)),
                  ),
                ],
              ),

              // Divider
              Container(
                height: 80.h,
                width: 1,
                color: const Color(0xFFF3F4F6),
                margin: EdgeInsets.symmetric(horizontal: 20.w),
              ),

              // Progress Bars (Left side in RTL)
              Expanded(
                child: Column(
                  children: [
                    CourseReviewsProgressBar(
                      stars: 5,
                      progress: (data.ratingsDistribution[5] ?? 0) / 100,
                      percentage:
                          '${(data.ratingsDistribution[5] ?? 0).round()}%',
                    ),
                    SizedBox(height: 8.h),
                    CourseReviewsProgressBar(
                      stars: 4,
                      progress: (data.ratingsDistribution[4] ?? 0) / 100,
                      percentage:
                          '${(data.ratingsDistribution[4] ?? 0).round()}%',
                    ),
                    SizedBox(height: 8.h),
                    CourseReviewsProgressBar(
                      stars: 3,
                      progress: (data.ratingsDistribution[3] ?? 0) / 100,
                      percentage:
                          '${(data.ratingsDistribution[3] ?? 0).round()}%',
                    ),
                    SizedBox(height: 8.h),
                    CourseReviewsProgressBar(
                      stars: 2,
                      progress: (data.ratingsDistribution[2] ?? 0) / 100,
                      percentage:
                          '${(data.ratingsDistribution[2] ?? 0).round()}%',
                    ),
                    SizedBox(height: 8.h),
                    CourseReviewsProgressBar(
                      stars: 1,
                      progress: (data.ratingsDistribution[1] ?? 0) / 100,
                      percentage:
                          '${(data.ratingsDistribution[1] ?? 0).round()}%',
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

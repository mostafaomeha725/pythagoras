import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';

import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_filter_button.dart';

class CourseReviewsFilterHeader extends StatelessWidget {
  final int totalReviews;
  final String currentSort;
  final Function(String) onSortChanged;

  const CourseReviewsFilterHeader({
    super.key,
    required this.totalReviews,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'آراء الطلاب',
              style: font18w700.copyWith(color: const Color(0xFF1E1E2D)),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF2F8), // Light pinkish red
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '$totalReviews رأياً',
                style: font12w700.copyWith(
                  color: const Color(0xFFBE185D),
                ), // Dark pinkish red
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CourseReviewsFilterButton(
              title: 'الأحدث',
              isActive: currentSort == 'latest',
              icon: Icons.sort_rounded,
              onTap: () => onSortChanged('latest'),
            ),
            SizedBox(width: 12.w),
            CourseReviewsFilterButton(
              title: 'الأعلى تقييماً',
              isActive: currentSort == 'highest',
              onTap: () => onSortChanged('highest'),
            ),
          ],
        ),
      ],
    );
  }
}

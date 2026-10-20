import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_sort_button.dart';

/// Filter & sorting bar for Course Reviews on Tablet Landscape.
class CourseReviewsTabletFilterBar extends StatelessWidget {
  final int totalReviews;
  final String currentSort;
  final ValueChanged<String> onSortChanged;

  const CourseReviewsTabletFilterBar({
    super.key,
    required this.totalReviews,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Title
        AppText(
          'آراء الطلاب',
          style: font18w700.copyWith(
            color: const Color(0xFF1E1E2D),
            fontSize: 17,
          ),
        ),
        const SizedBox(width: 10),

        // Count Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF2F8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: AppText(
            '$totalReviews رأياً',
            style: font12w700.copyWith(
              color: const Color(0xFFBE185D),
              fontSize: 11.5,
            ),
          ),
        ),
        const Spacer(),

        // Sorting Buttons
        CourseReviewsTabletSortButton(
          title: 'الأحدث',
          isActive: currentSort == 'latest',
          icon: Icons.schedule_rounded,
          onTap: () => onSortChanged('latest'),
        ),
        const SizedBox(width: 8),
        CourseReviewsTabletSortButton(
          title: 'الأعلى تقييماً',
          isActive: currentSort == 'highest',
          icon: Icons.star_rounded,
          onTap: () => onSortChanged('highest'),
        ),
      ],
    );
  }
}

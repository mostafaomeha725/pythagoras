import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_image.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_review_stars.dart';

/// Single review card for Tablet Landscape.
class CourseReviewsTabletReviewCard extends StatelessWidget {
  final String name;
  final String date;
  final double rating;
  final String reviewText;
  final String imageUrl;

  const CourseReviewsTabletReviewCard({
    super.key,
    required this.name,
    required this.date,
    required this.rating,
    required this.reviewText,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: AppImage(
                  imageUrl: imageUrl,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      name,
                      style: font14w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    CourseReviewsTabletReviewStars(rating: rating),
                  ],
                ),
              ),
              AppText(
                date,
                style: font10w400.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (reviewText.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            AppText(
              reviewText,
              style: font12w400.copyWith(
                color: const Color(0xFF334155),
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Rating stars row with score display for single review cards on Tablet Landscape.
class CourseReviewsTabletReviewStars extends StatelessWidget {
  final double rating;

  const CourseReviewsTabletReviewStars({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          rating.toStringAsFixed(1),
          style: font10w700.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          final isFilled = index < rating.floor();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: const Color(0xFFFBBF24),
              size: 13,
            ),
          );
        }),
      ],
    );
  }
}

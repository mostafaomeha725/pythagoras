import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Single progress bar row for star rating distribution on Tablet Landscape.
class CourseReviewsTabletDistributionRow extends StatelessWidget {
  final int stars;
  final double percent;

  const CourseReviewsTabletDistributionRow({
    super.key,
    required this.stars,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            child: AppText(
              '$stars',
              style: font12w700.copyWith(
                color: const Color(0xFF334155),
                fontSize: 11,
              ),
            ),
          ),
          const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 11),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFBBF24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: AppText(
              '${percent.round()}%',
              style: font12w400.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 11,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Interactive rating stars selector for Tablet Landscape.
class CourseReviewsTabletAddStars extends StatelessWidget {
  final int rating;
  final bool showRatingError;
  final ValueChanged<int> onRatingChanged;

  const CourseReviewsTabletAddStars({
    super.key,
    required this.rating,
    required this.showRatingError,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isSelected = index < rating;
            return GestureDetector(
              onTap: () => onRatingChanged(index + 1),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFFBEB) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFDE68A)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isSelected
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFCBD5E1),
                  size: 20,
                ),
              ),
            );
          }),
        ),
        if (showRatingError) ...[
          const SizedBox(height: 5),
          AppText(
            'لم تختر تقييماً بعد',
            style: font10w400.copyWith(
              color: const Color(0xFFDC2626),
              fontSize: 11,
            ),
            alignment: AlignmentDirectional.center,
          ),
        ],
      ],
    );
  }
}

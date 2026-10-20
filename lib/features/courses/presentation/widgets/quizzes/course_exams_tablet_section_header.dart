import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Section header row (title + pill) optimized for Tablet Landscape.
class CourseExamsTabletSectionHeader extends StatelessWidget {
  final String title;
  final String pillText;

  const CourseExamsTabletSectionHeader({
    super.key,
    required this.title,
    required this.pillText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          title,
          style: font20w700.copyWith(
            color: const Color(0xFF1E1E2D),
            fontSize: 20,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF4FA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: AppText(
            pillText,
            style: font12w700.copyWith(
              color: const Color(0xFF832561),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

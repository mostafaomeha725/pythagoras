import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class CourseStarRow extends StatelessWidget {
  final double rating;
  final bool tabletLandscape;

  const CourseStarRow({
    super.key,
    required this.rating,
    this.tabletLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: tabletLandscape ? 22 : 16.sp,
          color: Colors.amber,
        ),
        SizedBox(width: tabletLandscape ? 6 : 4.w),
        AppText(
          rating.toStringAsFixed(1),
          style: tabletLandscape
              ? font12w700.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 16,
                )
              : font12w700.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

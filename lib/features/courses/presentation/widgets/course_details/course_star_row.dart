import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class CourseStarRow extends StatelessWidget {
  final double rating;

  const CourseStarRow({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 16.sp, color: Colors.amber),
        SizedBox(width: 4.w),
        AppText(
          rating.toStringAsFixed(1),
          style: font12w700.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

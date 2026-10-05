import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';

class CourseReviewsProgressBar extends StatelessWidget {
  final int stars;
  final double progress;
  final String percentage;

  const CourseReviewsProgressBar({
    super.key,
    required this.stars,
    required this.progress,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              stars.toString(),
              style: font12w700.copyWith(color: const Color(0xFF1E1E2D)),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.star_rounded,
              color: const Color(0xFFFBBF24),
              size: 12.sp,
            ),
          ],
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFBBF24)),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: 40.w,
          child: Text(
            percentage,
            style: font12w400.copyWith(color: const Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }
}

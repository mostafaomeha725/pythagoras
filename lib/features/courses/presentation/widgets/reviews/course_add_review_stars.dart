import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/theme/styles.dart';

class CourseAddReviewStars extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final bool showRatingError;

  const CourseAddReviewStars({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    required this.showRatingError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isSelected = index < rating;
            return GestureDetector(
              onTap: () => onRatingChanged(index + 1),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFFBEB) : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFDE68A) : const Color(0xFFF3F4F6),
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFFD1D5DB),
                  size: 24.sp,
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 12.h),
        if (showRatingError)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: const Color(0xFFDC2626), size: 14.sp),
              SizedBox(width: 4.w),
              AppText(
                'لم تختر تقييماً بعد',
                style: font10w400.copyWith(color: const Color(0xFFDC2626)),
              ),
            ],
          ),
        if (showRatingError) SizedBox(height: 24.h),
        if (!showRatingError) SizedBox(height: 12.h),
      ],
    );
  }
}

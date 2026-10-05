import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';

class CourseReviewsFilterButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;

  const CourseReviewsFilterButton({
    super.key,
    required this.title,
    required this.isActive,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppLightColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: isActive ? null : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16.sp,
                color: isActive ? Colors.white : const Color(0xFF6B7280),
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              title,
              style: font14w500.copyWith(
                color: isActive ? Colors.white : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class CourseReviewHeaderInfo extends StatelessWidget {
  final String title;
  const CourseReviewHeaderInfo({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF6EEF5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                Icons.menu_book_rounded,
                color: AppLightColors.primary,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: font16w700.copyWith(color: const Color(0xFF1E1E2D)),
                  maxLines: 2,
                ),
                SizedBox(height: 4.h),
                AppText(
                  'تجارب حقيقية من طلاب الدورة',
                  style: font12w400.copyWith(color: const Color(0xFF6B7280)),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF6EEF5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'الدورة',
              style: font12w700.copyWith(color: AppLightColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

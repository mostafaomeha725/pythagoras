import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class FeatureCardItem extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;

  const FeatureCardItem({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EEF5), // Light purple background as in image
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppLightColors.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                icon,
                style: TextStyle(fontSize: 24.sp),
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
                  style: font14w700.copyWith(color: AppLightColors.primary),
                  maxLines: 2,
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 8.h),
                AppText(
                  desc,
                  style: font12w500.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

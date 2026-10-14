import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Title, price, and arrow button info section for [CourseCard].
class CourseCardInfo extends StatelessWidget {
  final String title;
  final double price;

  const CourseCardInfo({super.key, required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: AppText(
                title,
                style: font16w700.copyWith(
                  color: const Color(0xFF1E1E2D),
                  height: 1.3,
                ),
                maxLines: 2,
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 32.w,
              height: 32.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFCEEFA),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_forward,
                  color: AppLightColors.primary,
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title,
            style: font16w700.copyWith(color: const Color(0xFF1E1E2D)),
            maxLines: 2,
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppText(
                    'دينار كويتي',
                    style: font14w600.copyWith(color: AppLightColors.primary),
                  ),
                  SizedBox(width: 4.w),
                  AppText(
                    price.toStringAsFixed(2),
                    style: font16w700.copyWith(color: AppLightColors.primary),
                  ),
                ],
              ),
              Container(
                width: 32.w,
                height: 32.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFCEEFA),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward,
                    color: AppLightColors.primary,
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

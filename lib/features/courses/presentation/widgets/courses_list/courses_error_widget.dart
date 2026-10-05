import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class CoursesErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CoursesErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2), // Light red background
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64.sp,
                color: const Color(0xFFEF4444), // Red color
              ),
            ),
            SizedBox(height: 24.h),
            AppText(
              "عذراً، حدث خطأ ما!",
              style: font18w700.copyWith(color: const Color(0xFF1E1E2D)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            AppText(
              message,
              style: font14w600.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppLightColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: AppText(
                  'إعادة المحاولة',
                  style: font16w700.copyWith(color: Colors.white),
                  alignment: AlignmentDirectional.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

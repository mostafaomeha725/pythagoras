import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CourseReviewsShimmer extends StatelessWidget {
  const CourseReviewsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Title Shimmer
            Container(
              width: 150.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              height: 28.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 24.h),

            // Add Review Form Shimmer
            Container(
              width: double.infinity,
              height: 180.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            SizedBox(height: 32.h),

            // Overall Rating Shimmer
            Container(
              width: double.infinity,
              height: 200.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            SizedBox(height: 32.h),

            // Filter Header Shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                Container(
                  width: 80.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Review Items Shimmer
            for (int i = 0; i < 3; i++) ...[
              Container(
                width: double.infinity,
                height: 140.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

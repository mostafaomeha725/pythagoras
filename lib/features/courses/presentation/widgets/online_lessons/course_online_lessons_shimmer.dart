import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CourseOnlineLessonsShimmer extends StatelessWidget {
  const CourseOnlineLessonsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Placeholder
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 24.h,
                      width: 120.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 14.h,
                      width: 150.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 20.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // Live Section Placeholder
            Container(
              height: 24.h,
              width: 100.w,
              margin: EdgeInsets.only(bottom: 16.h, left: 240.w), // Keep it on the right side in RTL
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            ...List.generate(
              1,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Container(
                  height: 140.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Upcoming Section Placeholder
            Container(
              height: 24.h,
              width: 100.w,
              margin: EdgeInsets.only(bottom: 16.h, left: 240.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            ...List.generate(
              2,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Container(
                  height: 140.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

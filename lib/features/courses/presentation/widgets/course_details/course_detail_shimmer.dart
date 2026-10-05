import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CourseDetailShimmer extends StatelessWidget {
  const CourseDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20.h),
            
            // Video / Thumbnail Placeholder
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            SizedBox(height: 20.h),
            
            // Title Placeholder
            Container(
              height: 24.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 24.h,
              width: 200.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            SizedBox(height: 16.h),
            
            // Meta chips
            Row(
              children: [
                Container(
                  height: 32.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  height: 32.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Price Placeholder
            Container(
              height: 20.h,
              width: 150.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            SizedBox(height: 20.h),
            
            // Description Placeholder
            ...List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Container(
                  height: 16.h,
                  width: index == 3 ? 150.w : double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 28.h),
            
            // Curriculum label Placeholder
            Container(
              height: 48.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            SizedBox(height: 16.h),
            
            // Chapters Placeholder
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Container(
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 120.h),
          ],
        ),
      ),
    );
  }
}

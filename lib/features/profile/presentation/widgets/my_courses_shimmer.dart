import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class MyCoursesShimmer extends StatelessWidget {
  const MyCoursesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(24.w),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4, // Show 4 skeleton cards
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFEDEDED), width: 1),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Image + Title + Instructor + Pill)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Placeholder
                    Container(
                      width: 84.w,
                      height: 84.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Info Placeholder
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            height: 16.h,
                            width: 120.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            height: 12.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          // Pill Placeholder
                          Container(
                            height: 24.h,
                            width: 80.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Progress Row Placeholder
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      height: 14.h,
                      width: 30.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Action Button Placeholder
                Container(
                  height: 48.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

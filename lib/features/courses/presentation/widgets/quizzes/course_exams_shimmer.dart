import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CourseExamsShimmer extends StatelessWidget {
  const CourseExamsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(24.w),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Stats Row Placeholder
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Container(
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Upcoming Header Placeholder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 24.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  Container(
                    height: 24.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Upcoming Cards Placeholders
              ...List.generate(
                2,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Container(
                    height: 130.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Completed Header Placeholder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 24.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  Container(
                    height: 24.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Completed Cards Placeholders
              ...List.generate(
                2,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Container(
                    height: 110.h,
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
      ],
    );
  }
}

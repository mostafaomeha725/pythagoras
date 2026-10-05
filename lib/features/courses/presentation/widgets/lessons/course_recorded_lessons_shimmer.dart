import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pythagoras/core/theme/light_colors.dart';

class CourseRecordedLessonsShimmer extends StatelessWidget {
  const CourseRecordedLessonsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Video Player Placeholder
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 220.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
        
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current Lesson Title
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
                    width: 250.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  // Description
                  Container(
                    height: 16.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 16.h,
                    width: 150.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  
                  // "محتوى الدورة" Header
                  Row(
                    children: [
                      Container(
                        height: 24.h,
                        width: 120.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        height: 24.h,
                        width: 100.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
                  // Chapters List
                  ...List.generate(
                    4,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Container(
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppLightColors.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

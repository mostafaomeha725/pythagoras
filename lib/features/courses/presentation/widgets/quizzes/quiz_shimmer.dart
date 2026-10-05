import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class QuizShimmer extends StatelessWidget {
  const QuizShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Card
                  Container(
                    width: double.infinity,
                    height: 70.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Question Card
                  Container(
                    width: double.infinity,
                    height: 150.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Options
                  ...List.generate(
                    4,
                    (index) => Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      width: double.infinity,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Action Buttons
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

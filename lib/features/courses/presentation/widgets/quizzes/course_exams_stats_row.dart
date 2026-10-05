import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class CourseExamsStatsRow extends StatelessWidget {
  final String averageScore;
  final int upcomingTasksCount;

  const CourseExamsStatsRow({
    super.key,
    required this.averageScore,
    required this.upcomingTasksCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Average Grade Box (Right in RTL)
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF4FA),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  averageScore,
                  style: font24w700.copyWith(
                    color: const Color(0xFF832561),
                    fontSize: 28.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                AppText(
                  'متوسط الدرجات',
                  style: font12w500.copyWith(color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // Upcoming Tasks Box (Left in RTL)
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8EA),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  upcomingTasksCount.toString(),
                  style: font24w700.copyWith(color: const Color(0xFFB45309)),
                ),
                SizedBox(height: 8.h),
                AppText(
                  'مهام قادمة',
                  style: font12w500.copyWith(color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

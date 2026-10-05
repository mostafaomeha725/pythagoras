import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_task.dart';

class CourseTaskUpcomingCard extends StatelessWidget {
  final CourseTask task;

  const CourseTaskUpcomingCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0x05000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Title and Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title and Subject
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      task.title,
                      style: font16w700.copyWith(color: const Color(0xFF1E1E2D)),
                      maxLines: 2,
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      '${task.subject} • ${task.subSubject}',
                      style: font12w700.copyWith(color: AppLightColors.primary),
                    ),
                  ],
                ),
              ),
              // Pill
              Container(
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: AppText(
                  'قادم',
                  style: font12w700.copyWith(color: const Color(0xFFC2410C)),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Bottom Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Calendar and Time
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.event_available_outlined,
                      color: const Color(0xFFC2410C),
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AppText(
                    'موعد التسليم: ${task.deadlineDateString}، ${task.deadlineTimeString}',
                    style: font12w500.copyWith(color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
              // Action Button
              BounceIt(
                onPressed: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppLightColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        task.actionLabel,
                        style: font14w700.copyWith(color: Colors.white),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        task.actionLabel == 'ابدأ'
                            ? Icons.play_arrow_rounded
                            : Icons.visibility_outlined,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ],
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

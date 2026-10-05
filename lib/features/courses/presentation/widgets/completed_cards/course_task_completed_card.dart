import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:pythagoras/features/courses/domain/entities/assignment_submission.dart';
import 'package:pythagoras/core/utils/date_formatter.dart';

class CourseTaskCompletedCard extends StatelessWidget {
  final CourseAssignment assignment;
  final AssignmentSubmission submission;

  const CourseTaskCompletedCard({
    super.key,
    required this.assignment,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFailed =
        submission.pointsAwarded != null &&
        submission.pointsAwarded! < (assignment.maxPoints / 2);

    final Color primaryColor = isFailed
        ? const Color(0xFFEF4444)
        : const Color(0xFF059669);
    final Color bgColor = isFailed
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFF0FDF4);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right Side: Checkmark, Title, Subject
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: AppText(
                        'واجب',
                        style: font10w700.copyWith(
                          color: const Color(0xFF2563EB),
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFailed
                            ? Icons.cancel_outlined
                            : Icons.check_circle_outline_rounded,
                        color: primaryColor,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Margin to align text vertically with the icon slightly
                      SizedBox(height: 28.h),
                      AppText(
                        assignment.title,
                        style: font14w700.copyWith(
                          color: const Color(0xFF1F2937),
                          height: 1.3,
                        ),
                        maxLines: 2,
                      ),
                      if (assignment.description != null &&
                          assignment.description!.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        AppText(
                          assignment.description!,
                          style: font12w500.copyWith(
                            color: const Color(0xFF6B7280),
                            height: 1.4,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // Removed Pill

          // Left Side: Score Box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  'الدرجة:',
                  style: font12w700.copyWith(color: primaryColor),
                ),
                SizedBox(height: 6.h),
                AppText(
                  submission.pointsAwarded != null
                      ? '${submission.pointsAwarded}/${assignment.maxPoints}'
                      : 'قيد المراجعة',
                  style: font14w700.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                AppText(
                  DateFormatter.format(submission.submittedAt),
                  style: font10w500.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 11.sp,
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

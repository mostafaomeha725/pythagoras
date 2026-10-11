import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_inline_result.dart';
import 'package:pythagoras/core/utils/date_formatter.dart';

class CourseQuizCompletedCard extends StatelessWidget {
  final CourseQuiz quiz;
  final QuizInlineResult? result;

  const CourseQuizCompletedCard({
    super.key,
    required this.quiz,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFailed = result != null && !result!.isPassed;
    final Color primaryColor = isFailed ? const Color(0xFFEF4444) : const Color(0xFF059669);
    final Color bgColor = isFailed ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 15,
            offset: Offset(0, 4),
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
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF4FA),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: AppText(
                        'امتحان',
                        style: font10w700.copyWith(color: const Color(0xFF832561), fontSize: 10.sp),
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
                        isFailed ? Icons.cancel_outlined : Icons.check_circle_outline_rounded,
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
                        quiz.title,
                        style: font14w700.copyWith(
                          color: const Color(0xFF1F2937),
                          height: 1.3,
                        ),
                        maxLines: 2,
                      ),
                      if (quiz.description != null && quiz.description!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        AppText(
                          quiz.description!,
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
                  result != null ? '${result!.score}/${quiz.totalMarks}' : '-/${quiz.totalMarks}',
                  style: font14w700.copyWith(color: primaryColor, fontSize: 16.sp, fontWeight: FontWeight.w800),
                ),
                if (result != null) ...[
                  SizedBox(height: 6.h),
                  AppText(
                    DateFormatter.formatYMD(result!.completedAt),
                    style: font10w500.copyWith(color: const Color(0xFF6B7280), fontSize: 11.sp),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

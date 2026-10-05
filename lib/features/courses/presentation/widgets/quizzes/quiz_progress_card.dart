import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class QuizProgressCard extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final int points;

  const QuizProgressCard({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (currentIndex + 1) / (totalQuestions > 0 ? totalQuestions : 1);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'السؤال ${currentIndex + 1} من $totalQuestions',
                style: font16w700.copyWith(color: const Color(0xFF1E1E2D)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6), // light orange
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: AppText(
                  '$points درجة',
                  style: font12w700.copyWith(color: const Color(0xFFD97706)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF832561)),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }
}

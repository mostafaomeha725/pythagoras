import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/widgets/app_image.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_question.dart';

class QuizQuestionCard extends StatelessWidget {
  final QuizQuestion question;

  const QuizQuestionCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    // Determine question type text
    String typeText = 'اختيار من متعدد';
    if (question.questionType.toLowerCase() == 'true_false' || 
        question.questionType.toLowerCase() == 'boolean') {
      typeText = 'صح أو غلط';
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'السؤال',
                style: font12w500.copyWith(color: const Color(0xFF6B7280)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF4FA),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: AppText(
                  typeText,
                  style: font10w700.copyWith(color: const Color(0xFF832561)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (question.questionText != null && question.questionText!.isNotEmpty)
            AppText(
              question.questionText!,
              style: font20w700.copyWith(color: const Color(0xFF1E1E2D)),
              maxLines: 20,
            ),
          
          if (question.imageUrl != null && question.imageUrl!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            AppImage(
              imageUrl: question.imageUrl!,
              width: double.infinity,
              fit: BoxFit.contain, // Show full image without cropping
              borderRadius: BorderRadius.circular(12.r),
            ),
          ],
        ],
      ),
    );
  }
}

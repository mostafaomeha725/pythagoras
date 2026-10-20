import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_image.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_question.dart';

/// Question Card displaying question text, type badge, and optional image for Tablet Landscape.
class QuizTabletQuestionCard extends StatelessWidget {
  final QuizQuestion question;

  const QuizTabletQuestionCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    String typeText = 'اختيار من متعدد';
    if (question.questionType.toLowerCase() == 'true_false' ||
        question.questionType.toLowerCase() == 'boolean') {
      typeText = 'صح أو غلط';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                style: font12w500.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 13,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF4FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AppText(
                  typeText,
                  style: font10w700.copyWith(
                    color: const Color(0xFF832561),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (question.questionText != null &&
              question.questionText!.isNotEmpty)
            AppText(
              question.questionText!,
              style: font20w700.copyWith(
                color: const Color(0xFF1E1E2D),
                fontSize: 18,
                height: 1.4,
              ),
              maxLines: 25,
            ),
          if (question.imageUrl != null && question.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppImage(
                imageUrl: question.imageUrl!,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

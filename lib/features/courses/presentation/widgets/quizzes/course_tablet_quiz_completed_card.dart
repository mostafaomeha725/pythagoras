import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/date_formatter.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_inline_result.dart';

/// Completed Quiz Card optimized for Tablet Landscape.
/// Uses explicit typography and paddings to prevent ScreenUtil scaling blowups.
class CourseTabletQuizCompletedCard extends StatelessWidget {
  final CourseQuiz quiz;
  final QuizInlineResult? result;

  const CourseTabletQuizCompletedCard({
    super.key,
    required this.quiz,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFailed = result != null && !result!.isPassed;
    final Color primaryColor =
        isFailed ? const Color(0xFFEF4444) : const Color(0xFF059669);
    final Color bgColor =
        isFailed ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Right Side: Badge + Icon + Title/Attempts
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF4FA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        'امتحان',
                        style: font10w700.copyWith(
                          color: const Color(0xFF832561),
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFailed
                            ? Icons.cancel_outlined
                            : Icons.check_circle_outline_rounded,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        quiz.title,
                        style: font14w700.copyWith(
                          color: const Color(0xFF1F2937),
                          fontSize: 14,
                          height: 1.3,
                        ),
                        maxLines: 2,
                      ),
                      if (quiz.description != null &&
                          quiz.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        AppText(
                          quiz.description!,
                          style: font12w500.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                        ),
                      ],
                      if (quiz.hasAttemptLimit) ...[
                        const SizedBox(height: 4),
                        AppText(
                          'المحاولة ${quiz.currentAttempts} من ${quiz.maxAttempts}',
                          style: font10w500.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 11,
                          ),
                        ),
                      ],
                      if (quiz.hasAttemptLimit ||
                          quiz.remainingAttempts != null) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.replay_rounded,
                              size: 12,
                              color: Color(0xFF832561),
                            ),
                            const SizedBox(width: 4),
                            AppText(
                              quiz.remainingAttemptsLabel,
                              style: font10w700.copyWith(
                                color: const Color(0xFF832561),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Left Side: Score Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppText(
                  'الدرجة:',
                  style: font12w700.copyWith(
                    color: primaryColor,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                AppText(
                  result != null
                      ? '${result!.score}/${quiz.totalMarks}'
                      : '-',
                  style: font14w700.copyWith(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (result?.completedAt != null) ...[
                  const SizedBox(height: 3),
                  AppText(
                    DateFormatter.format(result!.completedAt),
                    style: font10w500.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 10,
                    ),
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

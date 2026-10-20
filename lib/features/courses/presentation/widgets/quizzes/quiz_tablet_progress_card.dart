import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Progress card displaying question index, total count, and points on Tablet Landscape.
class QuizTabletProgressCard extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final int points;

  const QuizTabletProgressCard({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        (currentIndex + 1) / (totalQuestions > 0 ? totalQuestions : 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'السؤال ${currentIndex + 1} من $totalQuestions',
                style: font16w700.copyWith(
                  color: const Color(0xFF1E1E2D),
                  fontSize: 15,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AppText(
                  '$points درجة',
                  style: font12w700.copyWith(
                    color: const Color(0xFFD97706),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF832561)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

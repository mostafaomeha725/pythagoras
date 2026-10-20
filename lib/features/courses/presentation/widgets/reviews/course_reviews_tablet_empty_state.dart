import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Dedicated empty state placeholder for Course Reviews on Tablet Landscape.
class CourseReviewsTabletEmptyState extends StatelessWidget {
  const CourseReviewsTabletEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFFCEEFA),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.rate_review_outlined,
                color: AppLightColors.primary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 14),
          AppText(
            'لا توجد تقييمات بعد',
            style: font16w700.copyWith(
              color: const Color(0xFF1E1E2D),
              fontSize: 16,
            ),
            alignment: AlignmentDirectional.center,
          ),
          const SizedBox(height: 6),
          AppText(
            'كن أول من يشارك تجربته مع هذه الدورة لمساعدة زملائك!',
            style: font12w400.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 12.5,
            ),
            alignment: AlignmentDirectional.center,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

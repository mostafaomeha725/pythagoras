import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Empty state widget for Tablet Landscape when there are no upcoming tasks.
class CourseExamsTabletEmptyState extends StatelessWidget {
  const CourseExamsTabletEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_turned_in_outlined,
              color: Color(0xFFD1D5DB),
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          AppText(
            'لا توجد مهام قادمة',
            style: font16w700.copyWith(
              color: const Color(0xFF374151),
              fontSize: 16,
            ),
            alignment: AlignmentDirectional.center,
          ),
          const SizedBox(height: 4),
          AppText(
            'أنت على اطلاع دائم بجميع مهامك!',
            style: font12w500.copyWith(
              color: const Color(0xFF9CA3AF),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            alignment: AlignmentDirectional.center,
          ),
        ],
      ),
    );
  }
}

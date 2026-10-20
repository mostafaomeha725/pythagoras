import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Header for Homework Submission Bottom Sheet on Tablet Landscape.
class SubmitAssignmentTabletHeader extends StatelessWidget {
  final String assignmentTitle;
  final VoidCallback onMySubmissions;
  final VoidCallback onClose;

  const SubmitAssignmentTabletHeader({
    super.key,
    required this.assignmentTitle,
    required this.onMySubmissions,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Close Button
        BounceIt(
          onPressed: onClose,
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.close_rounded,
                color: Color(0xFF64748B),
                size: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Title and Assignment Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                'تسليم الواجب',
                style: font16w700.copyWith(
                  color: const Color(0xFF1E1E2D),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              AppText(
                assignmentTitle,
                style: font12w400.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11.5,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // "تسليماتي" Button
        BounceIt(
          onPressed: onMySubmissions,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF6EEF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF832561),
                  size: 14,
                ),
                const SizedBox(width: 4),
                AppText(
                  'تسليماتي',
                  style: font12w700.copyWith(
                    color: const Color(0xFF832561),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

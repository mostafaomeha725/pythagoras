import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Actions row (Submit & Cancel buttons) for Tablet Landscape Homework Submission.
class SubmitAssignmentTabletActions extends StatelessWidget {
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const SubmitAssignmentTabletActions({
    super.key,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BounceIt(
            onPressed: onSubmit,
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppLightColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppLightColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: AppText(
                  'تسليم الواجب',
                  style: font14w700.copyWith(color: Colors.white, fontSize: 14),
                  alignment: AlignmentDirectional.center,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        BounceIt(
          onPressed: onCancel,
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: AppText(
                'إلغاء',
                style: font14w600.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 13.5,
                ),
                alignment: AlignmentDirectional.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

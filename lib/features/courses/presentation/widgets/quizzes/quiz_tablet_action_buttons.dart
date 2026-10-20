import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Navigation action buttons for Tablet Landscape quiz (Previous & Next / Finish).
class QuizTabletActionButtons extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isSubmitting;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;

  const QuizTabletActionButtons({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.isSubmitting,
    required this.onNext,
    required this.onPrevious,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isFirst) ...[
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: isSubmitting ? null : onPrevious,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppLightColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: AppText(
                  'السابق',
                  style: font16w700.copyWith(
                    color: AppLightColors.primary,
                    fontSize: 14,
                  ),
                  alignment: AlignmentDirectional.center,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : (isLast ? onSubmit : onNext),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF832561),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : AppText(
                      isLast ? 'إنهاء الاختبار' : 'السؤال التالي',
                      style: font16w700.copyWith(
                        color: Colors.white,
                        fontSize: 14,
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

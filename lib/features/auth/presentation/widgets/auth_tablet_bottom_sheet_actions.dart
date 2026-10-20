import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Pinned Action Buttons (Cancel / Login) for Tablet Landscape Auth Bottom Sheet.
class AuthTabletBottomSheetActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onLogin;

  const AuthTabletBottomSheetActions({
    super.key,
    required this.onCancel,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: BounceIt(
            onPressed: onCancel,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: AppText(
                'إلغاء',
                style: font14w600.copyWith(
                  color: const Color(0xFF1E1E2D),
                  fontSize: 13.5,
                ),
                alignment: AlignmentDirectional.center,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Login Button
        Expanded(
          child: BounceIt(
            onPressed: onLogin,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppLightColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppLightColors.primary.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: AppText(
                'تسجيل الدخول',
                style: font14w600.copyWith(
                  color: Colors.white,
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

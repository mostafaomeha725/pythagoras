import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Tablet Landscape confirmation dialog for user logout.
/// Provides balanced proportions and fixed typography without ScreenUtil distortion.
class LogoutTabletDialog extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const LogoutTabletDialog({
    super.key,
    required this.isLoading,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Red Logout Icon
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFEF4444),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              AppText(
                'هل تريد تسجيل الخروج؟',
                style: font18w700.copyWith(
                  color: const Color(0xFF1E1E2D),
                  fontSize: 17.5,
                ),
                alignment: AlignmentDirectional.center,
              ),
              const SizedBox(height: 6),

              // Subtitle
              AppText(
                'سيتم إنهاء جلستك الحالية سريعا.',
                style: font12w500.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 13,
                ),
                alignment: AlignmentDirectional.center,
              ),
              const SizedBox(height: 20),

              // Buttons Row
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: BounceIt(
                      onPressed: () {
                        if (!isLoading) {
                          onCancel();
                        }
                      },
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: AppText(
                          'إلغاء',
                          style: font14w600.copyWith(
                            color: const Color(0xFF4B5563),
                            fontSize: 13.5,
                          ),
                          alignment: AlignmentDirectional.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Confirm Logout Button
                  Expanded(
                    child: BounceIt(
                      onPressed: () {
                        if (!isLoading) {
                          onConfirm();
                        }
                      },
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppLightColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: AppText(
                          'تسجيل الخروج',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

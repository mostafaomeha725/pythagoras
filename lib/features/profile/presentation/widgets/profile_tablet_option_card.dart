import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/domain/entities/profile_option.dart';

/// Option Card customized for Tablet Landscape with fixed height and crisp typography.
class ProfileTabletOptionCard extends StatelessWidget {
  final ProfileOption option;

  const ProfileTabletOptionCard({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    final bool isDestructive = option.isDestructive;
    final Color primaryColor = isDestructive
        ? const Color(0xFFEF4444)
        : const Color(0xFF1E1E2D);
    final Color iconColor = isDestructive
        ? const Color(0xFFEF4444)
        : const Color(0xFF832561);
    final Color bgColor = isDestructive
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFFDF4FA);

    String? effectiveSubtitle = option.subtitle;
    if (effectiveSubtitle == null || effectiveSubtitle.isEmpty) {
      if (option.title.contains('تعديل')) {
        effectiveSubtitle = 'تحديث البيانات الشخصية وكلمة المرور';
      } else if (option.title.contains('تسجيل الخروج')) {
        effectiveSubtitle = 'تسجيل الخروج من الحساب بأمان';
      }
    }

    return BounceIt(
      onPressed: option.onTap ?? () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        constraints: const BoxConstraints(minHeight: 72),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive
                ? const Color(0xFFFEE2E2)
                : const Color(0xFFE2E8F0),
            width: 1.1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Leading Icon Container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(option.icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    option.title,
                    style: font16w700.copyWith(
                      color: primaryColor,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                  ),
                  if (effectiveSubtitle != null) ...[
                    const SizedBox(height: 3),
                    AppText(
                      effectiveSubtitle,
                      style: font12w500.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 12.5,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),

            // Trailing Chevron
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF94A3B8),
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Account Status Badge, Platform Info Box, and Motto Banner for Profile Header Card.
class ProfileTabletHeaderBadges extends StatelessWidget {
  const ProfileTabletHeaderBadges({super.key});

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveHelper.isTabletLandscape(context)) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Account Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDCFCE7), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF16A34A),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(
                  "حساب الطالب: نشط ومسجل",
                  style: font14w600.copyWith(
                    color: const Color(0xFF15803D),
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Platform Info Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 18,
                color: Color(0xFF832561),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(
                  "منصة فيثاغورس التعليمية",
                  style: font14w600.copyWith(
                    color: const Color(0xFF334155),
                    fontSize: 12.5,
                  ),
                ),
              ),
              AppText(
                "v1.0.0",
                style: font12w500.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Motivational Student Motto Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF832561).withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 15,
                color: Color(0xFF832561),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText(
                  "«معاً نحو التفوق والدرجات النهائية»",
                  style: font12w500.copyWith(
                    color: const Color(0xFF832561),
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

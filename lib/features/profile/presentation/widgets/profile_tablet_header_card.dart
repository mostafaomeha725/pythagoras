import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_tablet_avatar.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_tablet_header_badges.dart';

/// User Profile Header Card customized for Tablet Landscape.
/// Composes avatar, student info, and platform badges into a unified card.
class ProfileTabletHeaderCard extends StatelessWidget {
  final String name;
  final String grade;
  final String? profilePictureUrl;
  final bool? showBadges;

  const ProfileTabletHeaderCard({
    super.key,
    required this.name,
    required this.grade,
    this.profilePictureUrl,
    this.showBadges,
  });

  @override
  Widget build(BuildContext context) {
    final shouldShowBadges =
        showBadges ?? ResponsiveHelper.isTabletLandscape(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          ProfileTabletAvatar(profilePictureUrl: profilePictureUrl),
          const SizedBox(height: 14),

          // Student Name
          AppText(
            name,
            style: font20w700.copyWith(
              color: const Color(0xFF1E1E2D),
              fontSize: 19,
            ),
            alignment: AlignmentDirectional.center,
          ),
          const SizedBox(height: 6),

          // Phone / Grade Chip
          if (grade.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.phone_iphone_rounded,
                    size: 15,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  AppText(
                    grade,
                    style: font14w500.copyWith(
                      color: const Color(0xFF475569),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

          if (shouldShowBadges) ...[
            const SizedBox(height: 18),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),

            // Status & Platform Badges
            const ProfileTabletHeaderBadges(),
          ],
        ],
      ),
    );
  }
}

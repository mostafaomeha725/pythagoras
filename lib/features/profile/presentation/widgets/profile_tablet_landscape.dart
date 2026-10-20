import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/domain/entities/profile_option.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_tablet_header_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_tablet_option_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_tablet_support_banner.dart';

/// 2-column balanced Tablet Landscape layout for Profile Screen.
/// Arranges student showcase on the right, action options on the left,
/// and a cohesive support banner below to eliminate empty space.
class ProfileTabletLandscape extends StatelessWidget {
  final String name;
  final String grade;
  final String? profilePictureUrl;
  final List<ProfileOption> options;
  final Future<void> Function() onRefresh;

  final double bottomPadding;

  const ProfileTabletLandscape({
    super.key,
    required this.name,
    required this.grade,
    this.profilePictureUrl,
    required this.options,
    required this.onRefresh,
    this.bottomPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF832561),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section Header
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'حسابي',
                    style: font20w700.copyWith(
                      color: const Color(0xFF1E1E2D),
                      fontSize: 22,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AppText(
                      'إدارة الحساب والإعدادات',
                      style: font12w500.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Two-Column or Balanced Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isTwoColumn = constraints.maxWidth >= 720;

                if (isTwoColumn) {
                  final headerWidth = constraints.maxWidth >= 850
                      ? 330.0
                      : 280.0;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Right Column (in RTL): Student Showcase Card
                      SizedBox(
                        width: headerWidth,
                        child: ProfileTabletHeaderCard(
                          name: name,
                          grade: grade,
                          profilePictureUrl: profilePictureUrl,
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Left Column (in RTL): Action Options in a single vertical stack
                      Expanded(
                        child: Column(
                          children: options
                              .map(
                                (opt) => ProfileTabletOptionCard(option: opt),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    ProfileTabletHeaderCard(
                      name: name,
                      grade: grade,
                      profilePictureUrl: profilePictureUrl,
                    ),
                    const SizedBox(height: 16),
                    ...options.map(
                      (opt) => ProfileTabletOptionCard(option: opt),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Bottom Full-Width Support Banner
            const ProfileTabletSupportBanner(),

            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}

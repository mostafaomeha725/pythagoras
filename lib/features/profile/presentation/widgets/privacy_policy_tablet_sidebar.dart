import 'package:flutter/material.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_tablet_contact_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_tablet_header_banner.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_tablet_web_card.dart';

/// Sidebar column for Privacy Policy in Tablet Landscape.
/// Groups Header banner, Official web card, and Support inquiries.
class PrivacyPolicyTabletSidebar extends StatelessWidget {
  const PrivacyPolicyTabletSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrivacyPolicyTabletHeaderBanner(),
        SizedBox(height: 14),
        PrivacyPolicyTabletWebCard(),
        SizedBox(height: 14),
        PrivacyPolicyTabletContactCard(),
      ],
    );
  }
}

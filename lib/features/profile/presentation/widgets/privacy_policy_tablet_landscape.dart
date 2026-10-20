import 'package:flutter/material.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_sections_data.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_tablet_section_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_tablet_sidebar.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_tablet_top_bar.dart';

/// Professional 2-Column Tablet Landscape layout for Privacy Policy.
/// Balances overview sidebar on the right and full legal sections on the left.
/// The TopBar is fixed at the top while the 9 legal sections scroll smoothly.
class PrivacyPolicyTabletLandscape extends StatelessWidget {
  const PrivacyPolicyTabletLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed Screen Header Bar
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: PrivacyPolicyTabletTopBar(),
        ),

        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTwoColumn = constraints.maxWidth >= 780;

                if (isTwoColumn) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Right Column (in RTL): Overview Sidebar (Banner, Web, Contact)
                          const SizedBox(
                            width: 340,
                            child: PrivacyPolicyTabletSidebar(),
                          ),
                          const SizedBox(width: 20),

                          // Left Column (in RTL): Full 9 Legal Sections
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: PrivacyPolicySectionsData.sections
                                  .map(
                                    (section) => PrivacyPolicyTabletSectionCard(
                                      title: section.title,
                                      icon: section.icon,
                                      points: section.points,
                                      note: section.note,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PrivacyPolicyTabletSidebar(),
                    const SizedBox(height: 16),
                    ...PrivacyPolicySectionsData.sections.map(
                      (section) => PrivacyPolicyTabletSectionCard(
                        title: section.title,
                        icon: section.icon,
                        points: section.points,
                        note: section.note,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

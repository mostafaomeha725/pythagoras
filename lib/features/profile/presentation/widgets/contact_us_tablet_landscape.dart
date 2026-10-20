import 'package:flutter/material.dart';
import 'package:pythagoras/features/profile/presentation/widgets/contact_us_tablet_form_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/contact_us_tablet_info_panel.dart';
import 'package:pythagoras/features/profile/presentation/widgets/contact_us_tablet_top_bar.dart';

/// Professional layout for Contact Us screen on Tablet.
/// Adapts gracefully: 2-column layout on wide screens (>= 820px) and
/// stacked single-column layout on narrower screens (< 820px) such as Small Tablet Portrait.
class ContactUsTabletLandscape extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController messageController;
  final VoidCallback onSubmit;

  const ContactUsTabletLandscape({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.messageController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed Top Bar with back button and subtitle badge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1140),
              child: const ContactUsTabletTopBar(),
            ),
          ),
        ),

        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1140),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isTwoColumn = constraints.maxWidth >= 820;

                    if (isTwoColumn) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 360,
                                child: ContactUsTabletInfoPanel(),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: ContactUsTabletFormCard(
                                  formKey: formKey,
                                  nameController: nameController,
                                  emailController: emailController,
                                  messageController: messageController,
                                  onSubmit: onSubmit,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ContactUsTabletInfoPanel(),
                        const SizedBox(height: 18),
                        ContactUsTabletFormCard(
                          formKey: formKey,
                          nameController: nameController,
                          emailController: emailController,
                          messageController: messageController,
                          onSubmit: onSubmit,
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

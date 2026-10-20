import 'package:flutter/material.dart';
import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';
import 'package:pythagoras/features/profile/presentation/widgets/edit_profile_tablet_form.dart';
import 'package:pythagoras/features/profile/presentation/widgets/edit_profile_tablet_sidebar.dart';
import 'package:pythagoras/features/profile/presentation/widgets/edit_profile_tablet_top_bar.dart';

/// Professional Tablet Landscape layout for Edit Profile Screen.
/// Arranges student identity card on the right and two-column form on the left.
/// The TopBar is fixed at the top while content scrolls smoothly.
class EditProfileTabletLandscape extends StatelessWidget {
  final UserProfile? userProfile;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final VoidCallback onBack;

  const EditProfileTabletLandscape({
    super.key,
    required this.userProfile,
    required this.nameController,
    required this.passwordController,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed Top Bar with Back action and Screen Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: EditProfileTabletTopBar(onBack: onBack),
        ),

        // Scrollable 2-Column Content Row
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Right Column: Identity Sidebar
                    SizedBox(
                      width: 320,
                      child: EditProfileTabletSidebar(userProfile: userProfile),
                    ),
                    const SizedBox(width: 20),

                    // Left Column: Form Fields & Actions Card
                    Expanded(
                      child: EditProfileTabletForm(
                        userProfile: userProfile,
                        nameController: nameController,
                        passwordController: passwordController,
                        onCancel: onBack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

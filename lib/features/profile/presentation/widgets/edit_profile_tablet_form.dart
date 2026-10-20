import 'package:flutter/material.dart';
import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';
import 'package:pythagoras/features/profile/presentation/widgets/edit_profile_tablet_action_buttons.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_tablet_text_field.dart';

/// Form Card customized for Edit Profile in Tablet Landscape.
/// Organizes inputs into a clean 2-column grid inside an elevated card.
class EditProfileTabletForm extends StatelessWidget {
  final UserProfile? userProfile;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final VoidCallback onCancel;

  const EditProfileTabletForm({
    super.key,
    required this.userProfile,
    required this.nameController,
    required this.passwordController,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Name (Editable) & Phone (Read Only)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ProfileTabletTextField(
                  label: 'الاسم',
                  controller: nameController,
                  readOnly: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ProfileTabletTextField(
                  label: 'رقم الهاتف',
                  initialValue: userProfile?.phone ?? 'رقم الهاتف',
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Row 2: Password (Editable) & Account Role (Read Only)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ProfileTabletTextField(
                  label: 'كلمة المرور',
                  hint: 'اتركه فارغاً إذا لم ترغب بتغييره',
                  controller: passwordController,
                  isPassword: true,
                  readOnly: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ProfileTabletTextField(
                  label: 'نوع الحساب',
                  initialValue: userProfile?.role ?? 'طالب',
                  readOnly: true,
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF6B7280),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Row 3: Country Code (Read Only)
          Row(
            children: [
              Expanded(
                child: ProfileTabletTextField(
                  label: 'كود الدولة',
                  initialValue: userProfile?.countryCode ?? '+966',
                  readOnly: true,
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF6B7280),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 28),

          // Actions: Save Changes & Cancel (Tablet Sized & Proportioned)
          EditProfileTabletActionButtons(
            userProfile: userProfile,
            nameController: nameController,
            passwordController: passwordController,
            onCancel: onCancel,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';
import 'package:pythagoras/features/profile/presentation/cubit/edit_profile/edit_profile_cubit.dart';

/// Professional action buttons (Save Changes & Cancel) for Edit Profile in Tablet Landscape.
/// Uses fixed pixel sizing to eliminate giant ScreenUtil text distortions.
class EditProfileTabletActionButtons extends StatelessWidget {
  final UserProfile? userProfile;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final VoidCallback onCancel;

  const EditProfileTabletActionButtons({
    super.key,
    required this.userProfile,
    required this.nameController,
    required this.passwordController,
    required this.onCancel,
  });

  void _handleSave(BuildContext context) {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      showError('الرجاء إدخال الاسم');
      return;
    }

    final password = passwordController.text.trim();
    final originalName = userProfile?.name ?? '';

    if (name == originalName && password.isEmpty) {
      showError('لم تقم بإجراء أي تغييرات');
      return;
    }

    context.read<EditProfileCubit>().saveChanges(
      name: name,
      password: password.isEmpty ? null : password,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Primary Action: Save Changes
        Expanded(
          flex: 3,
          child: BounceIt(
            onPressed: () => _handleSave(context),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF832561),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF832561).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  AppText(
                    'حفظ التغييرات',
                    style: font16w700.copyWith(
                      color: Colors.white,
                      fontSize: 14.5,
                    ),
                    alignment: AlignmentDirectional.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Secondary Action: Cancel
        Expanded(
          flex: 2,
          child: BounceIt(
            onPressed: onCancel,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  AppText(
                    'إلغاء',
                    style: font16w700.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 14.5,
                    ),
                    alignment: AlignmentDirectional.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

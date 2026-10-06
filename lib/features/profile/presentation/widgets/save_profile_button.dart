import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';
import 'package:pythagoras/features/profile/presentation/cubit/edit_profile/edit_profile_cubit.dart';

class SaveProfileButton extends StatelessWidget {
  final UserProfile? userProfile;
  final TextEditingController nameController;
  final TextEditingController passwordController;

  const SaveProfileButton({
    super.key,
    required this.userProfile,
    required this.nameController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return BounceIt(
      onPressed: () {
        final name = nameController.text.trim();
        if (name.isEmpty) {
          showError('الرجاء إدخال الاسم');
          return;
        }

        final password = passwordController.text.trim();
        final originalName = userProfile?.name ?? '';
        final hasImageChanged =
            context.read<EditProfileCubit>().selectedImage != null;

        if (name == originalName && password.isEmpty && !hasImageChanged) {
          showError('لم تقم بإجراء أي تغييرات');
          return;
        }

        context.read<EditProfileCubit>().saveChanges(
          name: name,
          password: password.isEmpty ? null : password,
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppLightColors.primary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: AppText(
          'حفظ التغييرات',
          style: font16w700.copyWith(color: Colors.white),
          alignment: AlignmentDirectional.center,
        ),
      ),
    );
  }
}

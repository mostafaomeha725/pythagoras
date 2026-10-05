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
import 'package:pythagoras/features/profile/presentation/cubit/edit_profile/edit_profile_state.dart';
import 'package:pythagoras/features/profile/presentation/widgets/edit_profile_avatar.dart';
import 'package:pythagoras/features/profile/presentation/widgets/edit_profile_form.dart';

class EditProfileScreenBody extends StatefulWidget {
  final UserProfile? userProfile;
  const EditProfileScreenBody({super.key, this.userProfile});

  @override
  State<EditProfileScreenBody> createState() => _EditProfileScreenBodyState();
}

class _EditProfileScreenBodyState extends State<EditProfileScreenBody> {
  late final TextEditingController nameController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userProfile?.name ?? '');
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileLoading) {
          showLoading();
        } else {
          hideLoading();
          if (state is EditProfileFailure) {
            showError(state.message);
          } else if (state is EditProfileSuccess) {
            showSuccess('تم حفظ التغييرات بنجاح');
            Navigator.pop(context, true);
          }
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar
              EditProfileAvatar(profilePictureUrl: widget.userProfile?.profilePictureUrl),
              
              SizedBox(height: 32.h),

              // Form Fields
              EditProfileForm(
                userProfile: widget.userProfile,
                nameController: nameController,
                passwordController: passwordController,
              ),

              SizedBox(height: 40.h),

              // Save Button
              BounceIt(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    showError('الرجاء إدخال الاسم');
                    return;
                  }
                  
                  final password = passwordController.text.trim();
                  final originalName = widget.userProfile?.name ?? '';
                  final hasImageChanged = context.read<EditProfileCubit>().selectedImage != null;

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
              ),
            ],
          ),
        );
      },
    );
  }
}


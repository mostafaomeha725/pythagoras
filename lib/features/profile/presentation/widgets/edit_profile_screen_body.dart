import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';

import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';
import 'package:pythagoras/features/profile/presentation/cubit/edit_profile/edit_profile_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/edit_profile/edit_profile_state.dart';
import 'package:pythagoras/features/profile/presentation/widgets/edit_profile_avatar.dart';
import 'package:pythagoras/features/profile/presentation/widgets/edit_profile_form.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/features/profile/presentation/widgets/discard_changes_dialog.dart';
import 'package:pythagoras/features/profile/presentation/widgets/save_profile_button.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';

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
    nameController = TextEditingController(
      text: widget.userProfile?.name ?? '',
    );
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    final name = nameController.text.trim();
    final password = passwordController.text.trim();
    final originalName = widget.userProfile?.name ?? '';

    return name != originalName || password.isNotEmpty;
  }

  bool _forcePop = false;

  void _onBackPress() async {
    if (!_hasUnsavedChanges) {
      setState(() {
        _forcePop = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
      return;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => const DiscardChangesDialog(),
    );

    if (shouldPop == true && mounted) {
      setState(() {
        _forcePop = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _forcePop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackPress();
      },
      child: Scaffold(
        appBar: CourseDetailAppBar(
          title: 'تعديل الملف الشخصي',
          onBack: _onBackPress,
        ),
        body: SafeArea(
          child: BlocConsumer<EditProfileCubit, EditProfileState>(
            listener: (context, state) {
              if (state is EditProfileLoading) {
                showLoading();
              } else {
                hideLoading();
                if (state is EditProfileFailure) {
                  showError(state.message);
                } else if (state is EditProfileSuccess) {
                  showSuccess('تم حفظ التغييرات بنجاح');
                  context.pop(true);
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
                    EditProfileAvatar(
                      profilePictureUrl: widget.userProfile?.profilePictureUrl,
                    ),

                    SizedBox(height: 32.h),

                    // Form Fields
                    EditProfileForm(
                      userProfile: widget.userProfile,
                      nameController: nameController,
                      passwordController: passwordController,
                    ),

                    SizedBox(height: 40.h),

                    // Save Button
                    SaveProfileButton(
                      userProfile: widget.userProfile,
                      nameController: nameController,
                      passwordController: passwordController,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

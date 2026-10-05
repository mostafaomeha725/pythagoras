import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_text_field.dart';

class EditProfileForm extends StatelessWidget {
  final UserProfile? userProfile;
  final TextEditingController? nameController;
  final TextEditingController? passwordController;

  const EditProfileForm({
    super.key,
    this.userProfile,
    this.nameController,
    this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name (Editable)
        ProfileTextField(
          label: 'الاسم',
          initialValue: nameController == null ? (userProfile?.name ?? 'الاسم') : null,
          controller: nameController,
          readOnly: false,
        ),
        SizedBox(height: 20.h),

        // Phone (New Field - Read Only)
        ProfileTextField(
          label: 'رقم الهاتف',
          initialValue: userProfile?.phone ?? 'رقم الهاتف',
          readOnly: true,
        ),
        SizedBox(height: 20.h),

        // Password (Editable)
        ProfileTextField(
          label: 'كلمة المرور',
          hint: 'اتركه فارغاً إذا لم ترغب بتغييره',
          controller: passwordController,
          isPassword: true,
          readOnly: false,
          suffixIcon: const Icon(
            Icons.visibility_outlined,
            color: Color(0xFF6B7280),
            size: 20,
          ),
        ),
        SizedBox(height: 20.h),

        // Educational Year (Read Only)
        ProfileTextField(
          label: 'نوع الحساب',
          initialValue: userProfile?.role ?? 'طالب',
          readOnly: true,
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF6B7280),
            size: 24,
          ),
        ),
        SizedBox(height: 20.h),

        // Country (Read Only)
        ProfileTextField(
          label: 'كود الدولة',
          initialValue: userProfile?.countryCode ?? '+966',
          readOnly: true,
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF6B7280),
            size: 24,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

import 'password_input.dart';
import 'phone_input.dart';

class LoginForm extends StatefulWidget {
  final void Function(String phone, String password) onSubmit;

  const LoginForm({super.key, required this.onSubmit});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Phone Label
        AppText(
          "رقم الهاتف",
          style: font14w700.copyWith(color: const Color(0xFF1E1E2D)),
          alignment: AlignmentDirectional.centerStart,
        ),
        SizedBox(height: 8.h),

        // Phone Input
        PhoneInput(controller: _phoneController),

        SizedBox(height: 20.h),

        // Password Label
        AppText(
          "كلمة المرور",
          style: font14w700.copyWith(color: const Color(0xFF1E1E2D)),
          alignment: AlignmentDirectional.centerStart,
          maxLines: 1,
        ),
        SizedBox(height: 8.h),

        // Password Input
        PasswordInput(controller: _passwordController),

        SizedBox(height: 40.h),

        // Login Button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppLightColors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AppButton(
            text: "تسجيل الدخول",
            onPressed: () {
              widget.onSubmit(
                _phoneController.text.trim(),
                _passwordController.text,
              );
            },
            radius: 16.r,
            height: 56.h,
            textColor: Colors.white,
            textSize: 16.sp,
            textWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

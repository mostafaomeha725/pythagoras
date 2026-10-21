import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_form_field.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/auth/presentation/cubit/ios_register_cubit.dart';
import 'package:pythagoras/features/auth/presentation/widgets/password_input.dart';
import 'package:pythagoras/features/auth/presentation/widgets/phone_input.dart';

import 'package:pythagoras/features/courses/domain/entities/student_class.dart';

import 'ios_register_class_dropdown.dart';

class IosRegisterForm extends StatefulWidget {
  final bool tabletLandscape;

  const IosRegisterForm({super.key, this.tabletLandscape = false});

  @override
  State<IosRegisterForm> createState() => _IosRegisterFormState();
}

class _IosRegisterFormState extends State<IosRegisterForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  StudentClass? _selectedClass;

  @override
  void initState() {
    super.initState();
    _selectedClass = context.read<IosRegisterCubit>().state.selectedClass;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    context.read<IosRegisterCubit>().register(
      name: _nameController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      selectedClass: _selectedClass,
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = widget.tabletLandscape
        ? font17w700.copyWith(color: const Color(0xFF1E1E2D), fontSize: 17)
        : font14w700.copyWith(color: const Color(0xFF1E1E2D));

    final verticalSpacing = SizedBox(
      height: widget.tabletLandscape ? 14 : 16.h,
    );
    final labelSpacing = SizedBox(height: 8.h);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          "الاسم الكامل",
          style: labelStyle,
          alignment: AlignmentDirectional.centerStart,
        ),
        labelSpacing,
        AppFormField(
          controller: _nameController,
          hintText: "أدخل الاسم الكامل",
          keyboardType: TextInputType.name,
          fillColor: const Color(0xFFF9FAFB),
          borderColor: const Color(0xFFE5E7EB),
          radius: widget.tabletLandscape ? 12 : 12.r,
          contentPadding: widget.tabletLandscape
              ? const EdgeInsets.symmetric(horizontal: 16)
              : null,
          maxLines: 1,
          textStyle: widget.tabletLandscape
              ? font14w600.copyWith(
                  color: const Color(0xFF1E1E2D),
                  fontSize: 17,
                )
              : null,
          hintStyle: widget.tabletLandscape
              ? font14w600.copyWith(color: Colors.grey, fontSize: 17)
              : null,
        ),

        verticalSpacing,

        AppText(
          "رقم الهاتف",
          style: labelStyle,
          alignment: AlignmentDirectional.centerStart,
        ),
        labelSpacing,
        PhoneInput(
          controller: _phoneController,
          tabletLandscape: widget.tabletLandscape,
        ),

        verticalSpacing,

        AppText(
          "كلمة المرور",
          style: labelStyle,
          alignment: AlignmentDirectional.centerStart,
          maxLines: 1,
        ),
        labelSpacing,
        PasswordInput(
          controller: _passwordController,
          tabletLandscape: widget.tabletLandscape,
        ),

        verticalSpacing,

        AppText(
          "الصف الدراسي",
          style: labelStyle,
          alignment: AlignmentDirectional.centerStart,
        ),
        labelSpacing,
        IosRegisterClassDropdown(
          tabletLandscape: widget.tabletLandscape,
          onChanged: (studentClass) {
            setState(() {
              _selectedClass = studentClass;
            });
          },
        ),
        SizedBox(height: widget.tabletLandscape ? 24 : 32.h),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.tabletLandscape ? 16 : 16.r,
            ),
            boxShadow: [
              BoxShadow(
                color: AppLightColors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AppButton(
            text: "إنشاء حساب",
            onPressed: _onSubmit,
            radius: widget.tabletLandscape ? 16 : 16.r,
            height: widget.tabletLandscape ? 62 : 56.h,
            textColor: Colors.white,
            textSize: widget.tabletLandscape ? 20 : 16.sp,
            textWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

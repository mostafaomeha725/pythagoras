import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class ProfileTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final bool isPassword;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const ProfileTextField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.isPassword = false,
    this.readOnly = false,
    this.suffixIcon,
    this.controller,
    this.onChanged,
  });

  @override
  State<ProfileTextField> createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<ProfileTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          widget.label,
          style: font14w700.copyWith(color: const Color(0xFF1E1E2D)),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.controller == null ? widget.initialValue : null,
          onChanged: widget.onChanged,
          obscureText: _obscureText,
          readOnly: widget.readOnly,
          style: font14w500.copyWith(color: const Color(0xFF1E1E2D)),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: font14w500.copyWith(color: const Color(0xFF9CA3AF)),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF6B7280),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppLightColors.primary),
            ),
            filled: true,
            fillColor: widget.readOnly ? const Color(0xFFF9FAFB) : Colors.white,
          ),
        ),
      ],
    );
  }
}

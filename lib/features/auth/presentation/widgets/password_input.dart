import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_form_field.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final bool tabletLandscape;

  const PasswordInput({
    super.key,
    required this.controller,
    this.tabletLandscape = false,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final input = Directionality(
      textDirection: TextDirection.ltr,
      child: AppFormField(
        controller: widget.controller,
        hintText: "••••••••",
        obsecureText: _obscureText,
        contentPadding: widget.tabletLandscape
            ? const EdgeInsets.symmetric(horizontal: 16)
            : null,
        textStyle: widget.tabletLandscape
            ? font14w500.copyWith(fontSize: 17, color: const Color(0xFF1E1E2D))
            : null,
        hintStyle: widget.tabletLandscape
            ? font14w500.copyWith(fontSize: 17, color: Colors.grey)
            : null,
        maxLines: 1,
        suffixIcon: BounceIt(
          child: InkWell(
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            borderRadius: BorderRadius.circular(50.r),
            child: Padding(
              padding: widget.tabletLandscape
                  ? const EdgeInsets.symmetric(horizontal: 16)
                  : EdgeInsets.symmetric(horizontal: 16.w),
              child: Icon(
                _obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF6B7280),
                size: widget.tabletLandscape ? 24 : 20.sp,
              ),
            ),
          ),
        ),
      ),
    );

    return widget.tabletLandscape ? SizedBox(height: 60, child: input) : input;
  }
}

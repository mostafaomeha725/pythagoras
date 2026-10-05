import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/widgets/app_form_field.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;

  const PasswordInput({
    super.key,
    required this.controller,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AppFormField(
        controller: widget.controller,
        hintText: "••••••••",
        obsecureText: _obscureText,
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
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Icon(
                _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF6B7280),
                size: 20.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

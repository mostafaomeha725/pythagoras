import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/widgets/app_form_field.dart';

class ContactTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextEditingController? controller;

  const ContactTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Provide a dummy controller if none is passed, just for UI
    final effectiveController = controller ?? TextEditingController();

    final Widget styledIcon = Container(
      padding: EdgeInsets.all(8.w),
      margin: EdgeInsets.symmetric(
        horizontal: 12.w,
      ), // spacing inside the prefix icon constraint
      decoration: BoxDecoration(
        color: const Color(0xFFFDF4FA),
        borderRadius: BorderRadius.circular(10.r), // matched radius
      ),
      child: Icon(icon, color: AppLightColors.primary, size: 20.w),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          style: font14w700.copyWith(color: const Color(0xFF1E1E2D)),
        ),
        SizedBox(height: 8.h),
        if (maxLines > 1)
          Stack(
            children: [
              AppFormField(
                controller: effectiveController,
                hintText: hint,
                maxLines: maxLines,
                contentPadding: EdgeInsets.only(
                  top: 16.h,
                  bottom: 16.h,
                  right: 60.w, // make room for the icon on the right (RTL)
                  left: 16.w,
                ),
              ),
              Positioned(
                top: 12.h,
                right: 0,
                child: styledIcon,
              ),
            ],
          )
        else
          AppFormField(
            controller: effectiveController,
            hintText: hint,
            maxLines: maxLines,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            prefixIcon: styledIcon,
          ),
      ],
    );
  }
}

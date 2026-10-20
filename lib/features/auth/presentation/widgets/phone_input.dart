import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_form_field.dart';

class PhoneInput extends StatelessWidget {
  final TextEditingController controller;
  final bool tabletLandscape;

  const PhoneInput({
    super.key,
    required this.controller,
    this.tabletLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    final input = Directionality(
      textDirection: TextDirection.ltr,
      child: AppFormField(
        controller: controller,
        hintText: "xxxxxxxx",
        keyboardType: TextInputType.phone,
        fillColor: const Color(0xFFF9FAFB),
        borderColor: const Color(0xFFE5E7EB),
        radius: tabletLandscape ? 12 : 12.r,
        contentPadding: tabletLandscape
            ? const EdgeInsets.symmetric(horizontal: 16)
            : null,
        maxLines: 1,
        textStyle: tabletLandscape
            ? font14w600.copyWith(color: const Color(0xFF1E1E2D), fontSize: 17)
            : null,
        hintStyle: tabletLandscape
            ? font14w600.copyWith(color: Colors.grey, fontSize: 17)
            : null,
        prefixIcon: Padding(
          padding: tabletLandscape
              ? const EdgeInsets.symmetric(horizontal: 16)
              : EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "🇰🇼",
                style: TextStyle(fontSize: tabletLandscape ? 24 : 20.sp),
              ),
              SizedBox(width: tabletLandscape ? 10 : 8.w),
              Text(
                "+965",
                textDirection: TextDirection.ltr,
                style: tabletLandscape
                    ? font14w600.copyWith(
                        color: const Color(0xFF1E1E2D),
                        fontSize: 17,
                      )
                    : font14w600.copyWith(color: const Color(0xFF1E1E2D)),
              ),
              SizedBox(width: tabletLandscape ? 10 : 8.w),
              Container(
                width: tabletLandscape ? 1 : 1.w,
                height: tabletLandscape ? 28 : 24.h,
                color: const Color(0xFFE5E7EB),
              ),
              SizedBox(width: tabletLandscape ? 4 : 4.w),
            ],
          ),
        ),
      ),
    );

    return tabletLandscape ? SizedBox(height: 60, child: input) : input;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_form_field.dart';

class PhoneInput extends StatelessWidget {
  final TextEditingController controller;

  const PhoneInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AppFormField(
        controller: controller,
        hintText: "xxxxxxxx",
        keyboardType: TextInputType.phone,
        fillColor: const Color(0xFFF9FAFB),
        borderColor: const Color(0xFFE5E7EB),
        radius: 12.r,
        maxLines: 1,
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "🇰🇼",
                style: TextStyle(fontSize: 20.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                "+965",
                textDirection: TextDirection.ltr,
                style: font14w600.copyWith(
                  color: const Color(0xFF1E1E2D),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 1.w,
                height: 24.h,
                color: const Color(0xFFE5E7EB),
              ),
              SizedBox(width: 4.w),
            ],
          ),
        ),
      ),
    );
  }
}

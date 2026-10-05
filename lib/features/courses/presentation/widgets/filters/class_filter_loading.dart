import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class ClassFilterLoading extends StatelessWidget {
  const ClassFilterLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppLightColors.primary,
            size: 20.sp,
          ),
          SizedBox(width: 6.w),
          AppText(
            "الصف الدراسي",
            style: font14w600.copyWith(color: const Color(0xFF1E1E2D)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class StatCardItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color bgColor;

  const StatCardItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Center(
              child: Text(icon, style: TextStyle(fontSize: 20.sp)),
            ),
          ),
          SizedBox(height: 12.h),
          AppText(
            value,
            style: font18w700.copyWith(color: AppLightColors.primary),
            alignment: AlignmentDirectional.center,
          ),
          SizedBox(height: 4.h),
          AppText(
            label,
            style: font12w500.copyWith(color: const Color(0xFF6B7280)),
            alignment: AlignmentDirectional.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

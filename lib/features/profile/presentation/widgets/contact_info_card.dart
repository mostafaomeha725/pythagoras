import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class ContactInfoCard extends StatelessWidget {
  final String text;
  final IconData icon;

  const ContactInfoCard({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Icon (first child = right side in RTL)
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF4FA),
              borderRadius: BorderRadius.circular(10.r), // matched radius
            ),
            child: Icon(icon, color: AppLightColors.primary, size: 20.w),
          ),
          SizedBox(width: 12.w),
          // Text (second child = left of icon in RTL)
          Expanded(
            child: AppText(
              text,
              style: font14w700.copyWith(color: const Color(0xFF1E1E2D)),
            ),
          ),
        ],
      ),
    );
  }
}

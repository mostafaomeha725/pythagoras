import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class CourseMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const CourseMetaChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: AppLightColors.primary),
        SizedBox(width: 4.w),
        AppText(
          label,
          style: font12w500.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

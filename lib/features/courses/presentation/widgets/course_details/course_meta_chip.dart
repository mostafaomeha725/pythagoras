import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class CourseMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool tabletLandscape;

  const CourseMetaChip({
    super.key,
    required this.icon,
    required this.label,
    this.tabletLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: tabletLandscape ? 20 : 16.sp,
          color: AppLightColors.primary,
        ),
        SizedBox(width: tabletLandscape ? 6 : 4.w),
        AppText(
          label,
          style: tabletLandscape
              ? font12w500.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 16,
                )
              : font12w500.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

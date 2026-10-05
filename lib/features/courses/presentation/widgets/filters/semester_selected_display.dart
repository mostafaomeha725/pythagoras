import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// The currently selected semester label shown inside the dropdown trigger.
class SemesterSelectedDisplay extends StatelessWidget {
  final String label;

  const SemesterSelectedDisplay({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.keyboard_arrow_down_rounded, color: AppLightColors.primary, size: 20.sp),
        SizedBox(width: 6.w),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: AppText(label, style: font14w600.copyWith(color: const Color(0xFF1E1E2D))),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class MyCourseProgressRow extends StatelessWidget {
  final int progressInt;
  const MyCourseProgressRow({super.key, required this.progressInt});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100.r),
          child: LinearProgressIndicator(
            value: progressInt / 100,
            minHeight: 6.h,
            backgroundColor: const Color(0xFFEDEDED),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppLightColors.primary,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // FIRST = RIGHT in RTL: 'مستمر بالدراسة' or completion text
            AppText(
              progressInt == 100 ? 'أتممت الدورة بنجاح' : 'مستمر بالدراسة',
              style: font12w500.copyWith(color: const Color(0xFF6B7280)),
            ),
            // LAST = LEFT in RTL: progress percent
            AppText(
              '$progressInt% مكتمل',
              style: font12w700.copyWith(color: AppLightColors.primary),
            ),
          ],
        ),
      ],
    );
  }
}

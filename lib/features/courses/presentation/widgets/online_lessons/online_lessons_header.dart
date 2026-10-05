import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Top header of [CourseOnlineLessonsScreenBody]: title + current date display.
class OnlineLessonsHeader extends StatelessWidget {
  final String dateLabel;

  const OnlineLessonsHeader({super.key, required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('جدول حصصك', style: font22w700.copyWith(color: const Color(0xFF1E1E2D))),
            SizedBox(height: 8.h),
            AppText('لا تفوّت موعدك القادم', style: font12w500.copyWith(color: const Color(0xFF9CA3AF))),
          ],
        ),
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 16.sp, color: AppLightColors.primary),
            SizedBox(width: 6.w),
            AppText(dateLabel, style: font12w700.copyWith(color: AppLightColors.primary)),
          ],
        ),
      ],
    );
  }
}

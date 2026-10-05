import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Section header: محتوى الدورة + chapter/lesson count pill.
class RecordedLessonsContentHeader extends StatelessWidget {
  final String countLabel;

  const RecordedLessonsContentHeader({super.key, required this.countLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText('محتوى الدورة', style: font18w700.copyWith(color: const Color(0xFF1E1E2D))),
        SizedBox(width: 12.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF6EEF5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: AppText(countLabel, style: font10w700.copyWith(color: AppLightColors.primary)),
        ),
      ],
    );
  }
}

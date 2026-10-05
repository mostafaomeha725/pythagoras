import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class CourseLessonDuration extends StatelessWidget {
  final int durationMinutes;
  final bool showStatuses;
  final bool isPlaying;

  const CourseLessonDuration({
    super.key,
    required this.durationMinutes,
    required this.showStatuses,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    if (showStatuses) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            color: isPlaying ? AppLightColors.primary : const Color(0xFF9CA3AF),
            size: 12.sp,
          ),
          SizedBox(width: 4.w),
          AppText(
            '$durationMinutes دقيقة',
            style: font10w700.copyWith(
              color: isPlaying ? AppLightColors.primary : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      );
    } else {
      return AppText(
        '$durationMinutes دقائق',
        style: font12w500.copyWith(color: const Color(0xFF9CA3AF)),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';

class CourseLessonIcon extends StatelessWidget {
  final bool isCompleted;
  final bool isPlaying;

  const CourseLessonIcon({
    super.key,
    required this.isCompleted,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        width: 30.w,
        height: 30.w,
        decoration: const BoxDecoration(
          color: Color(0xFFE5F8ED),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.check_rounded,
            color: const Color(0xFF10B981),
            size: 16.sp,
          ),
        ),
      );
    } else if (isPlaying) {
      return Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: AppLightColors.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 16.sp,
          ),
        ),
      );
    } else {
      return Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF6EEF5),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppLightColors.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.play_arrow_rounded,
            color: AppLightColors.primary,
            size: 16.sp,
          ),
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';

class CourseLessonIcon extends StatelessWidget {
  final bool isCompleted;
  final bool isPlaying;
  final bool tabletLandscape;

  const CourseLessonIcon({
    super.key,
    required this.isCompleted,
    required this.isPlaying,
    this.tabletLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    final double iconBoxSize = tabletLandscape ? 34 : 30.w;
    final double iconSize = tabletLandscape ? 18 : 16.sp;

    if (isCompleted) {
      return Container(
        width: iconBoxSize,
        height: iconBoxSize,
        decoration: const BoxDecoration(
          color: Color(0xFFE5F8ED),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.check_rounded,
            color: const Color(0xFF10B981),
            size: iconSize,
          ),
        ),
      );
    } else if (isPlaying) {
      return Container(
        width: iconBoxSize,
        height: iconBoxSize,
        decoration: const BoxDecoration(
          color: AppLightColors.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      );
    } else {
      return Container(
        width: iconBoxSize,
        height: iconBoxSize,
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
            size: iconSize,
          ),
        ),
      );
    }
  }
}

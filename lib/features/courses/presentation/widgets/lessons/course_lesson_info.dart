import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class CourseLessonInfo extends StatelessWidget {
  final String title;
  final bool isPlaying;
  final bool isCompleted;

  const CourseLessonInfo({
    super.key,
    required this.title,
    required this.isPlaying,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          style: (isPlaying ? font14w700 : font14w600).copyWith(
            color: isPlaying ? AppLightColors.primary : const Color(0xFF1E1E2D),
          ),
          maxLines: 2,
        ),
        if (isPlaying) ...[
          SizedBox(height: 4.h),
          AppText(
            'يُعرض الان',
            style: font10w700.copyWith(color: AppLightColors.primary),
          ),
        ] else if (isCompleted) ...[
          SizedBox(height: 4.h),
          AppText(
            'مكتمل',
            style: font10w700.copyWith(color: const Color(0xFF10B981)),
          ),
        ],
      ],
    );
  }
}

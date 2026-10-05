import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class OnlineLessonDetailItem extends StatelessWidget {
  final String text;
  final IconData icon;

  const OnlineLessonDetailItem({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: const Color(0xFF9CA3AF)),
        SizedBox(width: 6.w),
        AppText(
          text,
          style: font12w500.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

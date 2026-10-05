import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class MyCourseCongratsBadge extends StatelessWidget {
  const MyCourseCongratsBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFF16A34A),
            size: 20,
          ),
          SizedBox(width: 8.w),
          AppText(
            'أحسنت! أكملت هذه الدورة بنجاح',
            style: font13w600.copyWith(color: const Color(0xFF16A34A)),
          ),
        ],
      ),
    );
  }
}

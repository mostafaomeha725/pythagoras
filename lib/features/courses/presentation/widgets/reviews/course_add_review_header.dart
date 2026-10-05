import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/theme/styles.dart';

class CourseAddReviewHeader extends StatelessWidget {
  const CourseAddReviewHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'أضف تقييمك',
          style: font18w700.copyWith(color: const Color(0xFF1E1E2D)),
        ),
        SizedBox(height: 4.h),
        AppText(
          'شارك تجربتك بصراحة لمساعدة طلاب آخرين',
          style: font12w400.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

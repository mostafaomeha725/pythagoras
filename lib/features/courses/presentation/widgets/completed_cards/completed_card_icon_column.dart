import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Type badge (امتحان/واجب) + pass/fail circle icon column.
/// Shared by [CourseQuizCompletedCard] and [CourseTaskCompletedCard].
class CompletedCardIconColumn extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Color labelBg;
  final bool isFailed;
  final Color primaryColor;
  final Color bgColor;

  const CompletedCardIconColumn({
    super.key,
    required this.label,
    required this.labelColor,
    required this.labelBg,
    required this.isFailed,
    required this.primaryColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(color: labelBg, borderRadius: BorderRadius.circular(6.r)),
          child: AppText(label, style: font10w700.copyWith(color: labelColor, fontSize: 10.sp)),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(
            isFailed ? Icons.cancel_outlined : Icons.check_circle_outline_rounded,
            color: primaryColor,
            size: 22.sp,
          ),
        ),
      ],
    );
  }
}

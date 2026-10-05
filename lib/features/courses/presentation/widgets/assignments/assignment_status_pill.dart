import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Status pill shown in the top-right corner of the assignment card.
/// Displays "قادم" (upcoming) in amber or "متأخر" (late) in red.
class AssignmentStatusPill extends StatelessWidget {
  final bool isLate;
  const AssignmentStatusPill({super.key, required this.isLate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isLate ? const Color(0xFFFEF2F2) : const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: AppText(
        isLate ? 'متأخر' : 'قادم',
        style: font12w700.copyWith(
          color: isLate ? const Color(0xFFEF4444) : const Color(0xFFD97706),
        ),
      ),
    );
  }
}

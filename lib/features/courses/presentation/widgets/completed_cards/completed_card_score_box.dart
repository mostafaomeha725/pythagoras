import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Score box on the right side of completed quiz/task cards.
class CompletedCardScoreBox extends StatelessWidget {
  final Color primaryColor;
  final Color bgColor;
  final String scoreText;
  final String? dateText;

  const CompletedCardScoreBox({
    super.key,
    required this.primaryColor,
    required this.bgColor,
    required this.scoreText,
    this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14.r)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText('الدرجة:', style: font12w700.copyWith(color: primaryColor)),
          SizedBox(height: 6.h),
          AppText(
            scoreText,
            style: font14w700.copyWith(color: primaryColor, fontSize: 16.sp, fontWeight: FontWeight.w800),
          ),
          if (dateText != null) ...[
            SizedBox(height: 6.h),
            AppText(dateText!, style: font10w500.copyWith(color: const Color(0xFF6B7280), fontSize: 11.sp)),
          ],
        ],
      ),
    );
  }
}

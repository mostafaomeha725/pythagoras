import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';

class CourseChapterBuyButton extends StatelessWidget {
  final String price;
  final String currencyLabel;
  final VoidCallback? onPressed;
  final bool isEnrolled;
  final String requestStatus;
  final bool tabletLandscape;

  const CourseChapterBuyButton({
    super.key,
    required this.price,
    required this.currencyLabel,
    this.onPressed,
    required this.isEnrolled,
    this.requestStatus = 'not_requested',
    this.tabletLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    // Parse the price to double first (to handle "0.00" or "35.00"), then cast to int
    final parsedPrice = double.tryParse(price)?.toInt() ?? 0;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final String requestText = isIOS
        ? 'طلب الحصة'
        : 'طلب الحصة ($parsedPrice $currencyLabel)';

    final buttonText = isEnrolled
        ? 'عرض الحصة'
        : (requestStatus == 'pending' ? 'قيد الانتظار' : requestText);

    return Padding(
      padding: tabletLandscape
          ? const EdgeInsets.fromLTRB(16, 10, 16, 14)
          : EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: AppButton(
        text: buttonText,
        onPressed: requestStatus == 'pending' ? () {} : (onPressed ?? () {}),
        radius: tabletLandscape ? 12 : 12.r,
        textSize: tabletLandscape ? 15 : 15.sp,
        height: tabletLandscape ? 48 : 48.h,
        contentPadding: tabletLandscape ? EdgeInsets.zero : null,
      ),
    );
  }
}

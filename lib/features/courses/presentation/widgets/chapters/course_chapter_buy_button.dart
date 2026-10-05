import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';

class CourseChapterBuyButton extends StatelessWidget {
  final String price;
  final String currencyLabel;
  final VoidCallback? onPressed;
  final bool isEnrolled;

  const CourseChapterBuyButton({
    super.key,
    required this.price,
    required this.currencyLabel,
    this.onPressed,
    required this.isEnrolled,
  });

  @override
  Widget build(BuildContext context) {
    // Parse the price to double first (to handle "0.00" or "35.00"), then cast to int
    final parsedPrice = double.tryParse(price)?.toInt() ?? 0;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: AppButton(
        text: isEnrolled ? 'عرض الحصة' : 'شراء الحصة ($parsedPrice $currencyLabel)',
        onPressed: onPressed ?? () {},
        radius: 12.r,
        textSize: 15.sp,
        height: 48.h,
      ),
    );
  }
}

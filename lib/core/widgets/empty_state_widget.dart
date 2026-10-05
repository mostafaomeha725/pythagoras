import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.subMessage,
    this.icon = Icons.inbox_rounded,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6), // Light gray background
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64.sp,
                color: const Color(0xFF9CA3AF), // Medium gray
              ),
            ),
            SizedBox(height: 24.h),
            AppText(
              message,
              style: font18w700.copyWith(color: const Color(0xFF1E1E2D)),
              textAlign: TextAlign.center,
              alignment: AlignmentDirectional.center,
            ),
            if (subMessage != null) ...[
              SizedBox(height: 8.h),
              AppText(
                subMessage!,
                style: font14w600.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
                alignment: AlignmentDirectional.center,
              ),
            ],
            if (onActionPressed != null && actionText != null) ...[
              SizedBox(height: 32.h),
              AppButton(
                text: actionText!,
                onPressed: onActionPressed,
                height: 50.h,
                radius: 16.r,
                color: AppLightColors.primary,
                textColor: Colors.white,
                textWeight: FontWeight.w700,
                textSize: 16.sp,
                elevation: 0,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

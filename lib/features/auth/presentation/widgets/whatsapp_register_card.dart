import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class WhatsAppRegisterCard extends StatelessWidget {
  final VoidCallback onTap;

  const WhatsAppRegisterCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BounceIt(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15.r,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // WhatsApp Icon inside circular background
              Container(
                width: 60.w,
                height: 60.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.phone_in_talk,
                    color: const Color(0xFF25D366),
                    size: 30.sp,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Card Title
              AppText(
                "التسجيل عبر واتساب",
                style: font18w700.copyWith(color: const Color(0xFF1E1E2D)),
                alignment: AlignmentDirectional.center,
              ),

              SizedBox(height: 8.h),

              // Card Subtitle
              AppText(
                "اضغط هنا للتواصل معنا وإكمال عملية التسجيل",
                style: font14w500.copyWith(color: const Color(0xFF6B7280)),
                alignment: AlignmentDirectional.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/constants/app_assets.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_asset.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:go_router/go_router.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16.h),

        // Top Right Back Button
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: BounceIt(
            child: InkWell(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                }
              },
              borderRadius: BorderRadius.circular(50.r),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFCEEFA),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppLightColors.primary,
                    size: 16.sp,
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 8.h),

        // Logo
        Align(
          alignment: Alignment.center,
          child: AppAsset(assetName: Assets.logo, height: 140.h),
        ),

        SizedBox(height: 22.h),

        // Heading
        AppText(
          "مرحباً بك مجدداً",
          style: font24w800.copyWith(color: const Color(0xFF1E1E2D)),
          alignment: AlignmentDirectional.center,
        ),

        SizedBox(height: 8.h),

        // Subtitle
        AppText(
          "الرجاء إدخال بياناتك لتسجيل الدخول إلى حسابك",
          style: font14w500.copyWith(color: const Color(0xFF6B7280)),
          alignment: AlignmentDirectional.center,
        ),
      ],
    );
  }
}

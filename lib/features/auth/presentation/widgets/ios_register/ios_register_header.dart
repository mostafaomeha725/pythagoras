import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/constants/app_assets.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_asset.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class IosRegisterHeader extends StatelessWidget {
  final bool showBackButton;
  final double? logoHeight;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const IosRegisterHeader({
    super.key,
    this.showBackButton = true,
    this.logoHeight,
    this.titleStyle,
    this.subtitleStyle,
  });

  static Widget backButton(
    BuildContext context, {
    double size = 36,
    double iconSize = 16,
    double? borderRadius,
    VoidCallback? onTap,
  }) {
    return BounceIt(
      child: InkWell(
        onTap:
            onTap ??
            () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(Routes.loginScreen);
              }
            },
        borderRadius: BorderRadius.circular(borderRadius ?? size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Color(0xFFFCEEFA),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppLightColors.primary,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showBackButton) ...[
          Align(
            alignment: AlignmentDirectional.topStart,
            child: backButton(
              context,
              size: 38.w,
              iconSize: 18.sp,
              borderRadius: 50.r,
            ),
          ),
          SizedBox(height: 12.h),
        ],

        Align(
          alignment: Alignment.center,
          child: AppAsset(
            assetName: Assets.logoapp,
            height: logoHeight ?? 140.h,
          ),
        ),

        SizedBox(height: 22.h),

        AppText(
          "إنشاء حساب جديد",
          style:
              titleStyle ?? font24w800.copyWith(color: const Color(0xFF1E1E2D)),
          alignment: AlignmentDirectional.center,
        ),

        SizedBox(height: 8.h),

        AppText(
          "الرجاء إدخال بياناتك لإنشاء حساب جديد",
          style:
              subtitleStyle ??
              font14w500.copyWith(color: const Color(0xFF6B7280)),
          alignment: AlignmentDirectional.center,
        ),
      ],
    );
  }
}

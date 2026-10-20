import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/constants/strings.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/url_launcher_helper.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class PrivacyPolicyContactCard extends StatelessWidget {
  const PrivacyPolicyContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppLightColors.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppLightColors.primary.withValues(alpha: 0.05),
            blurRadius: 14.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF4FA),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.mail_outline_rounded,
                  color: AppLightColors.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'لديك استفسار حول الخصوصية؟',
                      style: font16w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      'info@neudrosi-pythagoras.com',
                      style: font13w500.copyWith(color: AppLightColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          BounceIt(
            onPressed: () =>
                UrlLauncherHelper.openUrl(AppStrings.privacyPolicyWebUrl),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppLightColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language_rounded,
                    color: AppLightColors.primary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: AppText(
                      'neudrosi-pythagoras.com/terms#privacy',
                      style: font12w500.copyWith(color: AppLightColors.primary),
                      textDirection: TextDirection.ltr,
                      maxLines: 1,
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    color: AppLightColors.primary.withValues(alpha: 0.6),
                    size: 14.sp,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          BounceIt(
            onPressed: () => context.push(Routes.contactUsScreen),
            child: AppButton(
              text: 'تواصل مع الدعم الفني',
              onPressed: () => context.push(Routes.contactUsScreen),
              radius: 12.r,
              height: 46.h,
              textSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

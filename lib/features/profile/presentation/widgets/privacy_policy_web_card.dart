import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/constants/strings.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/url_launcher_helper.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class PrivacyPolicyWebCard extends StatelessWidget {
  const PrivacyPolicyWebCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppLightColors.primary.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppLightColors.primary.withValues(alpha: 0.06),
            blurRadius: 16.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppLightColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.language_rounded,
                  color: AppLightColors.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'النسخة الرسمية عبر الويب',
                      style: font16w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    AppText(
                      'Terms & Privacy | Pythagoras',
                      style: font12w500.copyWith(color: AppLightColors.primary),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: const Color(0xFF10B981),
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    AppText(
                      'معتمد',
                      style: font10w700.copyWith(
                        color: const Color(0xFF047857),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Description
          AppText(
            'يمكنك في أي وقت الاطلاع على النسخة المعتمدة والمحدثة رقمياً من سياسة الخصوصية والشروط والأحكام عبر الرابط الرسمي للمنصة على الويب:',
            style: font12w400.copyWith(
              color: const Color(0xFF4B5563),
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.visible,
          ),
          SizedBox(height: 12.h),

          // URL Banner Link
          BounceIt(
            onPressed: () =>
                UrlLauncherHelper.openUrl(AppStrings.privacyPolicyWebUrl),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppLightColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.link_rounded,
                    color: AppLightColors.primary,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: AppText(
                      'neudrosi-pythagoras.com/terms#privacy',
                      style: font13w600.copyWith(
                        color: AppLightColors.primary,
                        fontSize: 12.sp,
                      ),
                      textDirection: TextDirection.ltr,
                      maxLines: 1,
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    color: AppLightColors.primary.withValues(alpha: 0.7),
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Action Button
          BounceIt(
            onPressed: () =>
                UrlLauncherHelper.openUrl(AppStrings.privacyPolicyWebUrl),
            child: AppButton(
              text: 'فتح سياسة الخصوصية في المتصفح',
              onPressed: () =>
                  UrlLauncherHelper.openUrl(AppStrings.privacyPolicyWebUrl),
              radius: 12.r,
              height: 44.h,
              textSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}

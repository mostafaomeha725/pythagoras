import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/constants/strings.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/url_launcher_helper.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class PrivacyPolicyHeaderBanner extends StatelessWidget {
  const PrivacyPolicyHeaderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppLightColors.primary, const Color(0xFF5B1248)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppLightColors.primary.withValues(alpha: 0.3),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'سياسة الخصوصية',
                      style: font18w700.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      'منصة فيثاغورث التعليمية • الكويت',
                      style: font12w500.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.update_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    AppText(
                      'آخر تحديث: ١٤ أكتوبر ٢٠٢٦',
                      style: font12w500.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
              BounceIt(
                onPressed: () =>
                    UrlLauncherHelper.openUrl(AppStrings.privacyPolicyWebUrl),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.language_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 6.w),
                      AppText(
                        'رابط الويب',
                        style: font12w700.copyWith(color: Colors.white),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.open_in_new_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 12.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AppText(
            'توضح هذه السياسة كيفية جمع بياناتك الشخصية واستخدامها وحمايتها عند استخدام منصة فيثاغورث، ونلتزم بالحفاظ على خصوصيتك وأمان بياناتك وفقاً للأنظمة واللوائح المعمول بها في دولة الكويت وبما يمتثل للمعايير الدولية لحماية خصوصية المستخدمين لدى متجري Apple و Google.',
            style: font13w500.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
            maxLines: 10,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}

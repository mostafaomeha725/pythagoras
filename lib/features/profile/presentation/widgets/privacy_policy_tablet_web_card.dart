import 'package:flutter/material.dart';
import 'package:pythagoras/core/constants/strings.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/url_launcher_helper.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Web version callout card for Privacy Policy tablet sidebar.
class PrivacyPolicyTabletWebCard extends StatelessWidget {
  const PrivacyPolicyTabletWebCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppLightColors.primary.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppLightColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.language_rounded,
                    color: AppLightColors.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'النسخة الرسمية عبر الويب',
                      style: font16w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      'Terms & Privacy | Pythagoras',
                      style: font12w500.copyWith(
                        color: AppLightColors.primary,
                        fontSize: 11,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF10B981),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    AppText(
                      'معتمد',
                      style: font10w700.copyWith(
                        color: const Color(0xFF047857),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          AppText(
            'يمكنك في أي وقت الاطلاع على النسخة المعتمدة والمحدثة رقمياً من سياسة الخصوصية والشروط والأحكام عبر الرابط الرسمي للمنصة على الويب:',
            style: font12w400.copyWith(
              color: const Color(0xFF4B5563),
              height: 1.55,
              fontSize: 12,
            ),
            maxLines: 4,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: 12),

          // URL Banner Link
          BounceIt(
            onPressed: () =>
                UrlLauncherHelper.openUrl(AppStrings.privacyPolicyWebUrl),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppLightColors.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.link_rounded,
                    color: AppLightColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText(
                      'neudrosi-pythagoras.com/terms#privacy',
                      style: font13w600.copyWith(
                        color: AppLightColors.primary,
                        fontSize: 11.5,
                      ),
                      textDirection: TextDirection.ltr,
                      maxLines: 1,
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    color: AppLightColors.primary.withValues(alpha: 0.7),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action Button
          BounceIt(
            onPressed: () =>
                UrlLauncherHelper.openUrl(AppStrings.privacyPolicyWebUrl),
            child: AppButton(
              text: 'فتح في المتصفح',
              onPressed: () =>
                  UrlLauncherHelper.openUrl(AppStrings.privacyPolicyWebUrl),
              radius: 10,
              height: 42,
              textSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

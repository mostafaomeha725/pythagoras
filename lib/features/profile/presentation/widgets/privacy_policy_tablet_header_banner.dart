import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Tablet Landscape header card for Privacy Policy sidebar.
class PrivacyPolicyTabletHeaderBanner extends StatelessWidget {
  const PrivacyPolicyTabletHeaderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppLightColors.primary, Color(0xFF5B1248)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppLightColors.primary.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'سياسة الخصوصية',
                      style: font18w700.copyWith(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      'منصة فيثاغورث التعليمية • الكويت',
                      style: font12w500.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Last update badge (sized to fit the date content)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.update_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: IntrinsicWidth(
                      child: AppText(
                        'آخر تحديث: ١٤ أكتوبر ٢٠٢٦',
                        style: font12w500.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          AppText(
            'توضح هذه السياسة كيفية جمع بياناتك الشخصية واستخدامها وحمايتها عند استخدام منصة فيثاغورث، ونلتزم بالحفاظ على خصوصيتك وأمان بياناتك وفقاً للأنظمة واللوائح المعمول بها في دولة الكويت وبما يمتثل للمعايير الدولية لحماية خصوصية المستخدمين لدى متجري Apple و Google.',
            style: font13w500.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.6,
              fontSize: 12.5,
            ),
            maxLines: 10,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}

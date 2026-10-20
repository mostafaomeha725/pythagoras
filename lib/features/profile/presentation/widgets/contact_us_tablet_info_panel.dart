import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/url_launcher_helper.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/presentation/widgets/contact_us_tablet_info_card.dart';

/// Contact info & support details panel for Tablet.
class ContactUsTabletInfoPanel extends StatelessWidget {
  const ContactUsTabletInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 520;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Support Overview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            Icons.headset_mic_rounded,
                            color: AppLightColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'نحن هنا لمساعدتك',
                              style: font16w700.copyWith(
                                color: const Color(0xFF1E1E2D),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              'قنوات التواصل المباشرة',
                              style: font12w500.copyWith(
                                color: const Color(0xFF6B7280),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    'هل لديك سؤال، أو تحتاج إلى مساعدة، أو تريد فقط أن تقول مرحباً؟ فريق الدعم لدينا هنا لمساعدتك.',
                    style: font14w500.copyWith(
                      color: const Color(0xFF4B5563),
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Phone & Email Cards
            if (isWide)
              Row(
                children: [
                  Expanded(
                    child: ContactUsTabletInfoCard(
                      label: 'رقم الهاتف / الواتساب',
                      value: '65608054',
                      icon: Icons.phone_in_talk_outlined,
                      onTap: () => UrlLauncherHelper.openUrl('tel:65608054'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ContactUsTabletInfoCard(
                      label: 'البريد الإلكتروني',
                      value: 'info@neudrosi-pythagoras.com',
                      icon: Icons.email_outlined,
                      onTap: () => UrlLauncherHelper.openUrl(
                        'mailto:info@neudrosi-pythagoras.com',
                      ),
                    ),
                  ),
                ],
              )
            else ...[
              ContactUsTabletInfoCard(
                label: 'رقم الهاتف / الواتساب',
                value: '65608054',
                icon: Icons.phone_in_talk_outlined,
                onTap: () => UrlLauncherHelper.openUrl('tel:65608054'),
              ),
              const SizedBox(height: 10),
              ContactUsTabletInfoCard(
                label: 'البريد الإلكتروني',
                value: 'info@neudrosi-pythagoras.com',
                icon: Icons.email_outlined,
                onTap: () => UrlLauncherHelper.openUrl(
                  'mailto:info@neudrosi-pythagoras.com',
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Working hours notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFF64748B),
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppText(
                      'أوقات الرد: نحرص على الرد على جميع الاستفسارات والرسائل بأسرع وقت ممكن.',
                      style: font12w500.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11.5,
                        height: 1.45,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Contact & Support Card for Privacy Policy in Tablet Landscape.
class PrivacyPolicyTabletContactCard extends StatelessWidget {
  const PrivacyPolicyTabletContactCard({super.key});

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
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF4FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppLightColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.mail_outline_rounded,
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
                      'لديك استفسار حول الخصوصية؟',
                      style: font16w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      'info@neudrosi-pythagoras.com',
                      style: font13w500.copyWith(
                        color: AppLightColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          BounceIt(
            onPressed: () => context.push(Routes.contactUsScreen),
            child: AppButton(
              text: 'تواصل مع الدعم الفني',
              onPressed: () => context.push(Routes.contactUsScreen),
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

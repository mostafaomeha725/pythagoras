import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Hero Card banner optimized for Tablet Landscape.
class HomeTabletHeroCard extends StatelessWidget {
  final VoidCallback onStartLearning;

  const HomeTabletHeroCard({super.key, required this.onStartLearning});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
      decoration: BoxDecoration(
        color: AppLightColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppLightColors.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  "منصتك الأفضل لتعلم الرياضيات بثقة وإتقان",
                  style: font20w700.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.35,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                AppText(
                  "ابدأ رحلتك في عالم الأرقام والمعادلات مع دورات عملية وتحديات تفاعلية",
                  style: font14w500.copyWith(
                    color: const Color(0xffE9D5FF),
                    fontSize: 14,
                    height: 1.45,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          BounceIt(
            onPressed: onStartLearning,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: AppText(
                  "ابدأ التعلم الآن",
                  style: font14w700.copyWith(
                    color: const Color(0xff4C1D95),
                    fontSize: 15,
                  ),
                  alignment: AlignmentDirectional.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

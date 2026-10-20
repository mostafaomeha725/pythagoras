import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Feature card item for Home Tablet Features.
class HomeTabletFeatureCard extends StatelessWidget {
  final Map<String, dynamic> feature;

  const HomeTabletFeatureCard({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EEF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0E4EF), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppLightColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: AppText(
                feature["icon"] as String,
                style: const TextStyle(fontSize: 22),
                alignment: AlignmentDirectional.center,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  feature["title"] as String,
                  style: font14w700.copyWith(
                    color: AppLightColors.primary,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 6),
                AppText(
                  feature["desc"] as String,
                  style: font12w500.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.45,
                    fontSize: 13,
                  ),
                  maxLines: 3,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

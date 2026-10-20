import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Card component for presenting a single Privacy Policy section in Tablet Landscape.
class PrivacyPolicyTabletSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> points;
  final String? note;

  const PrivacyPolicyTabletSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.points,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Row
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
                child: Center(
                  child: Icon(icon, color: AppLightColors.primary, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AppText(
                  title,
                  style: font16w700.copyWith(
                    color: const Color(0xFF1E1E2D),
                    fontSize: 16.5,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Points List
          ...points.map((point) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppLightColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppText(
                      point,
                      style: font14w400.copyWith(
                        color: const Color(0xFF374151),
                        height: 1.68,
                        fontSize: 13.5,
                      ),
                      maxLines: 25,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Optional Note Callout
          if (note != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppLightColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppText(
                      note!,
                      style: font12w500.copyWith(
                        color: const Color(0xFF4B5563),
                        height: 1.55,
                        fontSize: 13,
                      ),
                      maxLines: 10,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

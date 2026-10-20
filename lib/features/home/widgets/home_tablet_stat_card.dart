import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Stat card item for Home Tablet Statistics.
class HomeTabletStatCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const HomeTabletStatCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item["bgColor"] as Color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                item["icon"] as String,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AppText(
            item["value"] as String,
            style: font18w700.copyWith(
              color: AppLightColors.primary,
              fontSize: 18,
            ),
            alignment: AlignmentDirectional.center,
          ),
          const SizedBox(height: 4),
          AppText(
            item["label"] as String,
            style: font12w500.copyWith(
              color: const Color(0xFF6B7280),
              fontSize: 12,
            ),
            alignment: AlignmentDirectional.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

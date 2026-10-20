import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Interactive sort button pill for Course Reviews on Tablet Landscape.
class CourseReviewsTabletSortButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final IconData icon;
  final VoidCallback onTap;

  const CourseReviewsTabletSortButton({
    super.key,
    required this.title,
    required this.isActive,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BounceIt(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? AppLightColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? AppLightColors.primary
                  : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppLightColors.primary.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              AppText(
                title,
                style: font12w500.copyWith(
                  color: isActive ? Colors.white : const Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Single option tile for [SubmitAssignmentSourceSheet] in Tablet mode.
class SubmitAssignmentSourceTabletOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SubmitAssignmentSourceTabletOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Fixed Icon Container
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppLightColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icon, color: AppLightColors.primary, size: 22),
                ),
              ),
              const SizedBox(width: 14),

              // Flexible Text Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      title,
                      style: font14w600.copyWith(
                        color: const Color(0xFF1E1E2D),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.visible,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      subtitle,
                      style: font12w400.copyWith(
                        color: const Color(0xFF6B7280),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                      overflow: TextOverflow.visible,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Trailing Chevron
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

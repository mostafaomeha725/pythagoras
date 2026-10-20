import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Unified, customizable top header bar for Tablet Landscape mode screens.
/// Supports back navigation, leading badges, titles, and trailing actions or subtitle badges.
class CourseDetailTabletTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? leading;
  final Widget? trailing;
  final String? subtitleBadge;
  final double titleFontSize;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const CourseDetailTabletTopBar({
    super.key,
    this.title = 'تفاصيل الدورة',
    this.onBack,
    this.leading,
    this.trailing,
    this.subtitleBadge,
    this.titleFontSize = 20,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.symmetric(vertical: 6);

    final content = Row(
      children: [
        // Circular Back Button (starts at right edge in RTL)
        BounceIt(
          child: InkWell(
            onTap: () {
              if (onBack != null) {
                onBack!();
              } else if (context.canPop()) {
                context.pop();
              } else {
                context.go(Routes.mainNavigationScreen);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFFCEEFA),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppLightColors.primary,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Optional Leading Widget (e.g. file badge)
        if (leading != null) ...[leading!, const SizedBox(width: 10)],

        // Screen Title
        if (trailing != null || subtitleBadge != null)
          Expanded(
            child: AppText(
              title,
              style: font20w700.copyWith(
                color: const Color(0xFF1E1E2D),
                fontSize: titleFontSize,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          AppText(
            title,
            style: font20w700.copyWith(
              color: const Color(0xFF1E1E2D),
              fontSize: titleFontSize,
            ),
          ),

        // Optional Trailing Action or Subtitle Badge
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ] else if (subtitleBadge != null) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: AppText(
              subtitleBadge!,
              style: font12w500.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );

    if (backgroundColor != null) {
      return Container(
        color: backgroundColor,
        padding: effectivePadding,
        child: content,
      );
    }

    return Padding(padding: effectivePadding, child: content);
  }
}

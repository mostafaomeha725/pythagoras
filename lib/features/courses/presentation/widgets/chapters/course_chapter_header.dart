import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class CourseChapterHeader extends StatelessWidget {
  final int index;
  final String title;
  final String? subtitle;
  final bool isExpanded;
  final bool isCompleted;
  final VoidCallback onTap;
  final bool tabletLandscape;

  const CourseChapterHeader({
    super.key,
    required this.index,
    required this.title,
    this.subtitle,
    required this.isExpanded,
    this.isCompleted = false,
    required this.onTap,
    this.tabletLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tabletLandscape ? 16 : 16.r),
      child: Padding(
        padding: tabletLandscape
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
            : EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: tabletLandscape ? 36 : 30.w,
              height: tabletLandscape ? 36 : 30.w,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : AppLightColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF10B981)
                      : AppLightColors.primary,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: AppText(
                  '$index',
                  style: tabletLandscape
                      ? font14w700.copyWith(color: Colors.white, fontSize: 15)
                      : font14w700.copyWith(color: Colors.white),
                  alignment: AlignmentDirectional.center,
                ),
              ),
            ),
            SizedBox(width: tabletLandscape ? 12 : 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    style: tabletLandscape
                        ? font16w700.copyWith(
                            color: const Color(0xFF1E1E2D),
                            fontSize: 16,
                          )
                        : font16w700.copyWith(color: const Color(0xFF1E1E2D)),
                    maxLines: 2,
                    overflow: tabletLandscape ? TextOverflow.visible : null,
                    textAlign: TextAlign.start,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: tabletLandscape ? 4 : 4.h),
                    AppText(
                      subtitle!,
                      style: tabletLandscape
                          ? font12w500.copyWith(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 12,
                            )
                          : font12w500.copyWith(color: const Color(0xFF9CA3AF)),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: tabletLandscape ? 8 : 8.w),
            // Collapse/Expand arrow — left side in RTL
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppLightColors.primary,
              size: tabletLandscape ? 22 : 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}

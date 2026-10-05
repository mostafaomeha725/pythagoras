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

  const CourseChapterHeader({
    super.key,
    required this.index,
    required this.title,
    this.subtitle,
    required this.isExpanded,
    this.isCompleted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF10B981) : AppLightColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? const Color(0xFF10B981) : AppLightColors.primary,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: AppText(
                  '$index',
                  style: font14w700.copyWith(color: Colors.white),
                  alignment: AlignmentDirectional.center,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    style: font16w700.copyWith(
                      color: const Color(0xFF1E1E2D),
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.start,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    AppText(
                      subtitle!,
                      style: font12w500.copyWith(
                        color: const Color(0xFF9CA3AF),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Collapse/Expand arrow — left side in RTL
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppLightColors.primary,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}

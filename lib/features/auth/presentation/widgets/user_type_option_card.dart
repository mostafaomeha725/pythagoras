import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class UserTypeOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const UserTypeOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isSelected ? AppLightColors.primary : const Color(0xFFE5E7EB);
    final backgroundColor = isSelected ? const Color(0xFFFDF7FB) : Colors.white;
    final iconBgColor =
        isSelected ? AppLightColors.primary : const Color(0xFFF3F4F6);
    final iconColor = isSelected ? Colors.white : const Color(0xFF6B7280);

    return BounceIt(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 28.sp,
                  ),
                ),
              ),

              SizedBox(width: 16.w),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      alignment: AlignmentDirectional.centerStart,
                      textAlign: TextAlign.start,
                      style: font18w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      subtitle,
                      alignment: AlignmentDirectional.centerStart,
                      textAlign: TextAlign.start,
                      style: font12w500.copyWith(
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12.w),

              // Indicator
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppLightColors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppLightColors.primary
                        : const Color(0xFFD1D5DB),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16.sp,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

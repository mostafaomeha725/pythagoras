import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/domain/entities/profile_option.dart';

class ProfileOptionCard extends StatelessWidget {
  final ProfileOption option;

  const ProfileOptionCard({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = option.isDestructive
        ? const Color(0xFFEF4444)
        : const Color(0xFF1E1E2D);
    final Color iconColor = option.isDestructive
        ? const Color(0xFFEF4444)
        : const Color(0xFF832561);
    final Color bgColor = option.isDestructive
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFFDF4FA);

    return BounceIt(
      onPressed: option.onTap ?? () {},
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon and Texts (Right side in RTL)
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(option.icon, color: iconColor, size: 24.sp),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          option.title,
                          style: font16w700.copyWith(color: primaryColor),
                        ),
                        if (option.subtitle != null) ...[
                          SizedBox(height: 4.h),
                          AppText(
                            option.subtitle!,
                            style: font12w500.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Left Arrow (Chevron)
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFF9CA3AF),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class AuthBottomSheet extends StatelessWidget {
  const AuthBottomSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => const AuthBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 24.h),

            // Icon
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFFFCEEFA), // Light primary shade
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: AppLightColors.primary,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            AppText(
              'يجب تسجيل الدخول أولًا',
              style: font18w700.copyWith(color: const Color(0xFF1E1E2D)),
              alignment: AlignmentDirectional.center,
            ),
            SizedBox(height: 8.h),

            // Subtitle
            AppText(
              'لإتمام هذا الإجراء، يُرجى تسجيل الدخول إلى حسابك للاستمرار وتجربة الميزات الكاملة.',
              style: font14w400.copyWith(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              alignment: AlignmentDirectional.center,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            SizedBox(height: 32.h),

            // Actions
            Row(
              children: [
                Expanded(
                  child: BounceIt(
                    onPressed: () => context.pop(false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: AppText(
                        'إلغاء',
                        style: font14w600.copyWith(
                          color: const Color(0xFF1E1E2D),
                        ),
                        alignment: AlignmentDirectional.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: BounceIt(
                    onPressed: () async {
                      // wait for login to finish, then pop the bottom sheet with the result
                      final result = await context.push(Routes.loginScreen, extra: true);
                      if (context.mounted) {
                        context.pop(result == true);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: AppLightColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppLightColors.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: AppText(
                        'تسجيل الدخول',
                        style: font14w600.copyWith(color: Colors.white),
                        alignment: AlignmentDirectional.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

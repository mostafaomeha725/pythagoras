import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';

class CourseDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  const CourseDetailAppBar({super.key, this.title = 'تفاصيل الدورة'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppLightColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppLightColors.primary,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),

                  // Title — centered
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: font18w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  // Placeholder to balance back button
                  SizedBox(width: 40.w),
                ],
              ),
            ),
          ),
          // Slim divider
          Divider(height: 1, thickness: 1, color: const Color(0xFFF0F0F0)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(64.h);
}

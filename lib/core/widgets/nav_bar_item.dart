import 'package:pythagoras/core/widgets/app_asset.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NavBarItem extends StatelessWidget {
  final String imageAsset;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavBarItem({
    super.key,
    required this.imageAsset,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color activeColor = AppLightColors.primary;
    Color inactiveColor = const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 75.w,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(isSelected ? 10.w : 6.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1,
                child: AppAsset(
                  assetName: imageAsset,
                  width: isSelected ? 28.sp : 26.sp,
                  height: isSelected ? 28.sp : 26.sp,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 6.h),
            // الاسم تحت الأيقونة
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              style: GoogleFonts.cairo(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: isSelected ? 12.sp : 10.sp,
                height: 1.2,
                letterSpacing: 0.2,
              ),
              child: AppText(
                label,
                maxLines: 1,
                alignment: AlignmentDirectional.center,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

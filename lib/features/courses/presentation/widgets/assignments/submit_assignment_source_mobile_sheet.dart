import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Mobile layout for [SubmitAssignmentSourceSheet].
class SubmitAssignmentSourceMobileSheet extends StatelessWidget {
  final VoidCallback onPickGallery;
  final VoidCallback onPickFileSystem;

  const SubmitAssignmentSourceMobileSheet({
    super.key,
    required this.onPickGallery,
    required this.onPickFileSystem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          AppText(
            'اختر طريقة الرفع',
            style: font16w700.copyWith(color: const Color(0xFF1E1E2D)),
          ),
          SizedBox(height: 16.h),
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppLightColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.photo_library_outlined,
                color: AppLightColors.primary,
                size: 24.sp,
              ),
            ),
            title: AppText(
              'معرض الصور (Photos)',
              style: font14w600.copyWith(color: const Color(0xFF1E1E2D)),
            ),
            subtitle: AppText(
              'اختيار صورة من ألبوم الصور مباشرة',
              style: font12w400.copyWith(color: const Color(0xFF6B7280)),
            ),
            onTap: () {
              Navigator.of(context).pop();
              onPickGallery();
            },
          ),
          Divider(height: 1.h, color: const Color(0xFFF3F4F6)),
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppLightColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.folder_open_outlined,
                color: AppLightColors.primary,
                size: 24.sp,
              ),
            ),
            title: AppText(
              'الملفات والمستندات (Files)',
              style: font14w600.copyWith(color: const Color(0xFF1E1E2D)),
            ),
            subtitle: AppText(
              'تصفح المستندات و iCloud Drive وملفات الجهاز',
              style: font12w400.copyWith(color: const Color(0xFF6B7280)),
            ),
            onTap: () {
              Navigator.of(context).pop();
              onPickFileSystem();
            },
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}

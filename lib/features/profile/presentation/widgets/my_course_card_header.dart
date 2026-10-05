import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_image.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/domain/entities/my_course_enrollment.dart';

class MyCourseCardHeader extends StatelessWidget {
  final MyCourseEnrollment enrollment;
  const MyCourseCardHeader({super.key, required this.enrollment});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail — FIRST = renders on RIGHT in RTL
        Container(
          width: 84.w,
          height: 84.w,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: AppImage(
              imageUrl: enrollment.course.coverUrl ?? '',
              width: 84.w,
              height: 84.w,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Course info — SECOND = renders on LEFT in RTL
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                enrollment.course.title,
                style: font16w700.copyWith(color: const Color(0xFF1E1E2D)),
                maxLines: 2,
              ),
              SizedBox(height: 6.h),
              AppText(
                enrollment.course.instructor?.name ?? '',
                style: font12w500.copyWith(color: const Color(0xFF6B7280)),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF4FA),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: AppText(
                      enrollment.status == 'in_progress' ? 'نشط' : 'منتهي',
                      style: font12w700.copyWith(color: AppLightColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

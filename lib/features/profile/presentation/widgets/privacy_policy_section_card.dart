import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class PrivacyPolicySectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> points;
  final String? note;

  const PrivacyPolicySectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.points,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF4FA),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: AppLightColors.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppText(
                  title,
                  style: font16w700.copyWith(
                    color: const Color(0xFF1E1E2D),
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Points List
          ...points.map((point) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 6.h),
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: AppLightColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AppText(
                      point,
                      style: font14w400.copyWith(
                        color: const Color(0xFF4B5563),
                        height: 1.6,
                      ),
                      maxLines: 20,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Optional Note / Callout
          if (note != null) ...[
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16.sp,
                    color: AppLightColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: AppText(
                      note!,
                      style: font12w500.copyWith(
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                      maxLines: 10,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

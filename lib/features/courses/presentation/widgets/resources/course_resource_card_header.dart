import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';

class CourseResourceCardHeader extends StatelessWidget {
  final CourseResource resource;

  const CourseResourceCardHeader({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // PDF Icon Box (Rightmost in RTL)
        Container(
          margin: EdgeInsets.only(left: 12.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Icon(
                Icons.description_outlined,
                color: const Color(0xFFEF4444),
                size: 24.sp,
              ),
              SizedBox(height: 4.h),
              AppText(
                resource.file?.extension?.toUpperCase() ?? resource.type?.toUpperCase() ?? 'PDF',
                style: font12w700.copyWith(
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
        // Title and Subtitle (Leftmost in RTL)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                resource.title,
                style: font16w700.copyWith(
                  color: const Color(0xFF1E1E2D),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 8.h),
              if (resource.description.isNotEmpty) ...[
                AppText(
                  resource.description,
                  style: font12w500.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

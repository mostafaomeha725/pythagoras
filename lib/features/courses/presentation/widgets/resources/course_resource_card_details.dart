import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';

class CourseResourceCardDetails extends StatelessWidget {
  final CourseResource resource;

  const CourseResourceCardDetails({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 4.w,
          decoration: const BoxDecoration(
            color: Color(0xFFD1D5DB),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Icon(
          Icons.calendar_today_outlined,
          size: 14.sp,
          color: const Color(0xFF9CA3AF),
        ),
        SizedBox(width: 4.w),
        AppText(
          'متاح الآن', // Placeholder since date isn't fully implemented in the model
          style: font12w500.copyWith(color: const Color(0xFF6B7280)),
        ),
        SizedBox(width: 8.w),
        Container(
          width: 4.w,
          height: 4.w,
          decoration: const BoxDecoration(
            color: Color(0xFFD1D5DB),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Icon(
          Icons.save_outlined,
          size: 14.sp,
          color: const Color(0xFF9CA3AF),
        ),
        SizedBox(width: 4.w),
        AppText(
          '${((resource.file?.size ?? 0) / (1024 * 1024)).toStringAsFixed(1)} م.ب',
          style: font12w500.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

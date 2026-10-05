import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class AssignmentCardFileBadge extends StatelessWidget {
  final String fileExt;
  const AssignmentCardFileBadge({super.key, required this.fileExt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, color: const Color(0xFFEF4444), size: 26.sp),
          SizedBox(height: 6.h),
          AppText(fileExt, style: font12w700.copyWith(color: const Color(0xFFEF4444))),
        ],
      ),
    );
  }
}

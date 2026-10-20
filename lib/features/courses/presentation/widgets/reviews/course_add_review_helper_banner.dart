import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/theme/styles.dart';

class CourseAddReviewHelperBanner extends StatelessWidget {
  const CourseAddReviewHelperBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.volunteer_activism_outlined,
            color: const Color(0xFFBE185D),
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: AppText(
              'رأيك يساعدنا على تحسين تجربة التعلّم وتطوير محتوى الدورة.',
              style: font10w500.copyWith(color: const Color(0xFFBE185D)),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

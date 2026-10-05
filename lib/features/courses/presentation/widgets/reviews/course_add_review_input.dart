import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/widgets/app_form_field.dart';
import 'package:pythagoras/core/theme/styles.dart';

import 'package:flutter/services.dart';

class CourseAddReviewInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const CourseAddReviewInput({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          AppFormField(
            controller: controller,
            maxLines: 4,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            onChanged: onChanged,
            hintText: 'اكتب رأيك عن الدورة...',
            contentPadding: EdgeInsets.all(16.w),
            borderWidth: 0,
            fillColor: Colors.transparent,
            radius: 12.r,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppText(
                  '${controller.text.length} / 500',
                  style: font10w400.copyWith(color: const Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

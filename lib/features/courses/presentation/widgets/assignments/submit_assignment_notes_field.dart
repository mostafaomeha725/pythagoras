import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_form_field.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class SubmitAssignmentNotesField extends StatelessWidget {
  final TextEditingController controller;

  const SubmitAssignmentNotesField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'الملاحظات',
          style: font14w700.copyWith(color: const Color(0xFF1E1E2D)),
        ),
        SizedBox(height: 8.h),
        AppFormField(
          controller: controller,
          hintText: 'اكتب ملاحظاتك هنا...',
          maxLines: 4,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }
}

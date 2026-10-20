import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_form_field.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Notes input field for Homework Submission on Tablet Landscape.
class SubmitAssignmentTabletNotesField extends StatelessWidget {
  final TextEditingController controller;

  const SubmitAssignmentTabletNotesField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'الملاحظات',
          style: font14w700.copyWith(
            color: const Color(0xFF1E1E2D),
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 6),
        AppFormField(
          controller: controller,
          hintText: 'اكتب ملاحظاتك هنا...',
          maxLines: 4,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          textStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1E1E2D),
            fontFamily: 'Cairo',
          ),
          hintStyle: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF94A3B8),
            fontFamily: 'Cairo',
          ),
          contentPadding: const EdgeInsets.all(12),
          radius: 10,
        ),
      ],
    );
  }
}

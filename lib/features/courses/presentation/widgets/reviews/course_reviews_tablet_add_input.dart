import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_form_field.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Comment input box with character counter for Course Reviews on Tablet Landscape.
class CourseReviewsTabletAddInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const CourseReviewsTabletAddInput({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          AppFormField(
            controller: controller,
            maxLines: 3,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            onChanged: onChanged,
            hintText: 'اكتب رأيك عن الدورة...',
            textStyle: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF1E1E2D),
              fontFamily: 'Cairo',
            ),
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
              fontFamily: 'Cairo',
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            borderWidth: 0,
            fillColor: Colors.transparent,
            radius: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppText(
                  '${controller.text.length} / 500',
                  style: font10w400.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

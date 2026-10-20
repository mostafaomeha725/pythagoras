import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Reusable Pill Content widget for Tablet Landscape Filter dropdowns.
/// Aligns label and down chevron compactly in the center without edge separation.
class CourseTabletFilterPillContent extends StatelessWidget {
  final String text;
  final bool isHighlighted;

  const CourseTabletFilterPillContent({
    super.key,
    required this.text,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: AppText(
                text,
                style: font14w600.copyWith(
                  color: isHighlighted
                      ? const Color(0xFF832561)
                      : const Color(0xFF1E1E2D),
                  fontSize: 13,
                ),
                alignment: AlignmentDirectional.center,
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isHighlighted
                ? const Color(0xFF832561)
                : const Color(0xFF6B7280),
            size: 19,
          ),
        ],
      ),
    );
  }
}

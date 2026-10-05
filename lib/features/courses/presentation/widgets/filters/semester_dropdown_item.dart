import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/semester_option.dart';

/// A single item inside the semester dropdown menu.
class SemesterDropdownItem extends StatelessWidget {
  final SemesterOption semester;
  final bool isSelected;

  const SemesterDropdownItem({super.key, required this.semester, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: isSelected ? AppLightColors.primary.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: AppText(
        semester.name,
        style: font12w700.copyWith(
          color: isSelected ? AppLightColors.primary : const Color(0xFF1E1E2D),
        ),
        textAlign: TextAlign.right,
      ),
    );
  }
}

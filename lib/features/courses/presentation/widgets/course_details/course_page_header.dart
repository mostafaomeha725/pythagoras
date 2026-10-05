import 'package:flutter/material.dart';

import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Reusable centered title header row with a back button (RTL-aware).
///
/// Layout: [back circle btn] [title — centered] [SizedBox balance]
class CoursePageHeader extends StatelessWidget {
  final String title;

  const CoursePageHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppText(
      title,
      style: font20w700.copyWith(color: const Color(0xFF1E1E2D)),
      alignment: AlignmentDirectional.center,
    );
  }
}

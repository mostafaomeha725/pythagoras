import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/presentation/widgets/filters/class_filter_dropdown.dart';
import 'package:pythagoras/features/courses/presentation/widgets/filters/semester_filter_dropdown.dart';

class CoursesFilterBar extends StatelessWidget {
  const CoursesFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: ClassFilterDropdown()),
        SizedBox(width: 8.w),
        const Expanded(child: SemesterFilterDropdown()),
      ],
    );
  }
}

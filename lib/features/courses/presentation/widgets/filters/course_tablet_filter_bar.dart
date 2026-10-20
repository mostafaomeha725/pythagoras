import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/filters/course_tablet_class_filter.dart';
import 'package:pythagoras/features/courses/presentation/widgets/filters/course_tablet_semester_filter.dart';

/// Professional, pixel-perfect filter bar for Courses in Tablet Landscape.
/// Composes clean capsule pills with centered icons and labels.
class CourseTabletFilterBar extends StatelessWidget {
  const CourseTabletFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CourseTabletClassFilter(),
        SizedBox(width: 12),
        CourseTabletSemesterFilter(),
      ],
    );
  }
}

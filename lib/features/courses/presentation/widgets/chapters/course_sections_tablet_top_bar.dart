import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';

/// Top bar for Course Sections Screen in Tablet Landscape mode.
/// Reuses [CourseDetailTabletTopBar] with the sections title.
class CourseSectionsTabletTopBar extends StatelessWidget {
  final double titleFontSize;
  final EdgeInsetsGeometry? padding;

  const CourseSectionsTabletTopBar({
    super.key,
    this.titleFontSize = 20,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CourseDetailTabletTopBar(
      title: 'أقسام الدورة',
      titleFontSize: titleFontSize,
      padding: padding,
    );
  }
}

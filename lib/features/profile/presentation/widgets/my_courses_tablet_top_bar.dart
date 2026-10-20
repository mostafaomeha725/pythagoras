import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';

/// Top bar for My Courses screen in Tablet Landscape mode.
/// Reuses [CourseDetailTabletTopBar] with course count badge.
class MyCoursesTabletTopBar extends StatelessWidget {
  final int? courseCount;

  const MyCoursesTabletTopBar({super.key, this.courseCount});

  @override
  Widget build(BuildContext context) {
    return CourseDetailTabletTopBar(
      title: 'دوراتي',
      titleFontSize: 21,
      subtitleBadge: (courseCount != null && courseCount! > 0)
          ? '$courseCount دورات مسجلة'
          : null,
      padding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}

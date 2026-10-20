import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/course_tablet_grid.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_course_tablet_shimmer_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_courses_tablet_top_bar.dart';

/// Dedicated Tablet Landscape shimmer layout for My Courses screen.
/// Renders a fixed top bar and a responsive 2 or 3-column grid of skeleton course cards.
class MyCoursesTabletShimmer extends StatelessWidget {
  final int columnCount;

  const MyCoursesTabletShimmer({super.key, this.columnCount = 2});

  @override
  Widget build(BuildContext context) {
    final itemCount = columnCount * 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed Top Bar during loading
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: MyCoursesTabletTopBar(),
        ),

        // Scrollable Grid of Shimmer Cards
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: CourseTabletGrid(
              columnCount: columnCount,
              spacing: 18,
              children: List.generate(
                itemCount,
                (index) => const MyCourseTabletShimmerCard(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

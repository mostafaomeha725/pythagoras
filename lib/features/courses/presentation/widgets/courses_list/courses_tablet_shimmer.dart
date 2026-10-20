import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/course_tablet_grid.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/course_tablet_shimmer_card.dart';

/// Dedicated Tablet shimmer layout for the Courses screen.
/// Renders a responsive multi-column grid of [CourseTabletShimmerCard] matching [CourseTabletGrid].
class CoursesTabletShimmer extends StatelessWidget {
  final int columnCount;
  final int itemCount;
  final double bottomPadding;

  const CoursesTabletShimmer({
    super.key,
    this.columnCount = 2,
    this.itemCount = 6,
    this.bottomPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          CourseTabletGrid(
            columnCount: columnCount,
            spacing: 18,
            children: List.generate(
              itemCount,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 18),
                child: CourseTabletShimmerCard(),
              ),
            ),
          ),
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_list.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_sidebar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_top_bar.dart';

/// Dedicated Tablet Landscape layout for Course Reviews.
class CourseReviewsTabletLandscape extends StatelessWidget {
  final int courseId;
  final String courseTitle;

  const CourseReviewsTabletLandscape({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed Top Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CourseReviewsTabletTopBar(courseTitle: courseTitle),
            ),
          ),
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTwoColumn = constraints.maxWidth >= 850;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: isTwoColumn
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Right Column (in RTL): Sidebar
                              SizedBox(
                                width: 380,
                                child: CourseReviewsTabletSidebar(
                                  courseId: courseId,
                                  courseTitle: courseTitle,
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Left Column (in RTL): Reviews List & Filters
                              Expanded(
                                child: CourseReviewsTabletList(
                                  courseId: courseId,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CourseReviewsTabletSidebar(
                                courseId: courseId,
                                courseTitle: courseTitle,
                              ),
                              const SizedBox(height: 20),
                              CourseReviewsTabletList(courseId: courseId),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

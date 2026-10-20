import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/course_tablet_online_lesson_shimmer_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/course_tasks_two_column_grid.dart';
import 'package:shimmer/shimmer.dart';

/// Dedicated Tablet Landscape shimmer layout for [CourseOnlineLessonsScreen].
/// Renders the fixed top bar and mirrors the 2-column online lessons grid.
class CourseOnlineLessonsTabletShimmer extends StatelessWidget {
  const CourseOnlineLessonsTabletShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed Top Bar
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: CourseDetailTabletTopBar(title: 'الحصص الأونلاين'),
        ),

        // Scrollable Shimmer Body
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[200]!,
              highlightColor: Colors.grey[50]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Header Card Skeleton
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 22,
                              width: 140,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 14,
                              width: 180,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 28,
                          width: 85,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Title Skeleton Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 20,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 22,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2-Column Grid of 4 lesson shimmer cards
                  const CourseTasksTwoColumnGrid(
                    children: [
                      CourseTabletOnlineLessonShimmerCard(),
                      CourseTabletOnlineLessonShimmerCard(),
                      CourseTabletOnlineLessonShimmerCard(),
                      CourseTabletOnlineLessonShimmerCard(),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

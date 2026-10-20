import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_curriculum_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_info_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_action_button.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';

/// Dedicated Tablet Landscape layout for [CourseDetailScreen].
/// Features a two-column card layout:
/// - Right Column: Curriculum card (Banner & Chapters)
/// - Left Column: Course info card (Image, Title, Ratings, Description)
/// - Fixed Bottom Action Button: Stays sticky on the screen aligned with the right column.
class CourseDetailTabletLandscape extends StatelessWidget {
  final CourseDetail course;
  final BoxConstraints constraints;

  const CourseDetailTabletLandscape({
    super.key,
    required this.course,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 20.0;
    final columnWidth =
        (constraints.maxWidth - horizontalPadding * 2 - 20.0) / 2;

    return Stack(
      children: [
        // ── Main Content Area ───────────────────────────────────────
        Positioned.fill(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fixed Top Header: Back Button + Title
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 8.0,
                  ),
                  child: CourseDetailTabletTopBar(),
                ),

                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: 4.0,
                      bottom: 84.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Right Column (Curriculum + Chapters)
                        Expanded(
                          child: CourseDetailCurriculumCard(
                            course: course,
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Left Column (Image + Title + Rating + Description)
                        Expanded(
                          child: CourseDetailInfoCard(
                            course: course,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Fixed Action Button ("عرض الدورة" / "طلب الدورة") ───────
        // In RTL: positioned at the bottom right, aligned with Curriculum Card
        Positioned(
          bottom: 16,
          right: horizontalPadding,
          width: columnWidth,
          child: CourseDetailTabletActionButton(course: course),
        ),
      ],
    );
  }
}

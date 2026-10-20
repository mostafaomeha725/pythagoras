import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';
import 'package:shimmer/shimmer.dart';

/// Dedicated Tablet Landscape shimmer layout for Course Detail Screen.
/// Mirrors the exact 2-column layout (Curriculum on right, Course info on left)
/// and fixed bottom action button of [CourseDetailTabletLandscape].
class CourseDetailTabletShimmer extends StatelessWidget {
  final BoxConstraints constraints;

  const CourseDetailTabletShimmer({
    super.key,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 20.0;
    final columnWidth =
        (constraints.maxWidth - horizontalPadding * 2 - 20.0) / 2;

    return Stack(
      children: [
        // Main Content Area
        Positioned.fill(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fixed Top Bar
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 8.0,
                  ),
                  child: CourseDetailTabletTopBar(),
                ),

                // Scrollable 2-Column Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: 4.0,
                      bottom: 84.0,
                    ),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[200]!,
                      highlightColor: Colors.grey[50]!,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Right Column (Curriculum Card Shimmer)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Banner Skeleton
                                  Container(
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Chapter Tile Skeletons
                                  ...List.generate(
                                    3,
                                    (index) => Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          // Left Column (Course Info Card Shimmer)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // 16:9 Image Skeleton
                                  AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Title Skeleton
                                  Container(
                                    height: 22,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 22,
                                    width: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Chips Row Skeleton
                                  Row(
                                    children: [
                                      Container(
                                        height: 28,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        height: 28,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Description Lines Skeleton
                                  Container(
                                    height: 14,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 14,
                                    width: 220,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
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
                ),
              ],
            ),
          ),
        ),

        // Fixed Action Button Skeleton at bottom right
        Positioned(
          bottom: 16,
          right: horizontalPadding,
          width: columnWidth,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[50]!,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

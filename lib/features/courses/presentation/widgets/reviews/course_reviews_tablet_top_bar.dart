import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';

/// Top bar for Course Reviews page on Tablet Landscape mode.
/// Reuses [CourseDetailTabletTopBar] with a course context badge.
class CourseReviewsTabletTopBar extends StatelessWidget {
  final String courseTitle;

  const CourseReviewsTabletTopBar({super.key, required this.courseTitle});

  @override
  Widget build(BuildContext context) {
    return CourseDetailTabletTopBar(
      title: 'تقييمات الدورة',
      padding: const EdgeInsets.symmetric(vertical: 8),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_rounded,
              color: AppLightColors.primary,
              size: 15,
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: AppText(
                courseTitle,
                style: font12w500.copyWith(
                  color: const Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

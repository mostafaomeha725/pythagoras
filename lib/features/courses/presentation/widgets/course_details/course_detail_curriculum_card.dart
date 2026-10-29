import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_chapter_tile.dart';

/// Right card for Course Details on Tablet Landscape:
/// Curriculum Header, Chapters List, and Bottom Action Button.
class CourseDetailCurriculumCard extends StatelessWidget {
  final CourseDetail course;
  final int? restoreChapterId;
  final void Function(int chapterId, bool isExpanded)?
  onChapterExpansionChanged;

  const CourseDetailCurriculumCard({
    super.key,
    required this.course,
    this.restoreChapterId,
    this.onChapterExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Curriculum Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppLightColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: AppText(
              'المنهج الدراسي',
              style: font16w700.copyWith(color: Colors.white, fontSize: 17),
              alignment: AlignmentDirectional.center,
            ),
          ),

          const SizedBox(height: 16),

          // Chapters List with tabletLandscape: true
          ...course.chapters.asMap().entries.map((entry) {
            return CourseChapterTile(
              chapter: entry.value,
              index: entry.key + 1,
              isEnrolled: course.isEnrolled,
              course: course,
              tabletLandscape: true,
              showRestoreButton: entry.value.id == restoreChapterId,
              onExpansionChanged: onChapterExpansionChanged,
            );
          }),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_chapter_tile.dart';

/// Chapters and lessons playlist for Tablet Landscape.
/// Formats the curriculum into a scrollable, bordered list with active indicator.
class CourseTabletRecordedChaptersList extends StatelessWidget {
  final CourseDetail course;
  final CourseLesson? selectedLesson;
  final ValueChanged<CourseLesson> onLessonTap;

  const CourseTabletRecordedChaptersList({
    super.key,
    required this.course,
    required this.selectedLesson,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    int totalVideos = 0;
    for (final chapter in course.chapters) {
      totalVideos += chapter.videos.length;
    }
    final String courseStatsLabel =
        '${course.chapters.length} فصل • $totalVideos دروس';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Playlist Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AppText(
                'محتوى الدورة',
                style: font18w700.copyWith(
                  color: const Color(0xFF1E1E2D),
                  fontSize: 17,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF4FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppText(
                courseStatsLabel,
                style: font10w700.copyWith(
                  color: AppLightColors.primary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Chapters List
        ...course.chapters.asMap().entries.map((entry) {
          final chapter = entry.value;
          int totalChapterSeconds = chapter.videos
              .fold(0, (sum, video) => sum + video.durationMinutes);
          int totalChapterMinutes = totalChapterSeconds ~/ 60;
          String subtitle =
              '${chapter.videos.length} دروس • $totalChapterMinutes دقيقة';

          return CourseChapterTile(
            chapter: chapter,
            index: entry.key + 1,
            isEnrolled: course.isEnrolled,
            course: course,
            showActionButtons: false,
            showLessonStatuses: true,
            subtitle: subtitle,
            backgroundColor: Colors.white,
            headerBackgroundColor: const Color(0xFFFDF4FA),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: const [],
            selectedLessonId: selectedLesson?.id,
            onLessonTap: onLessonTap,
            tabletLandscape: true,
          );
        }),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_chapter_tile.dart';

class CourseRecordedChaptersList extends StatelessWidget {
  final CourseDetail course;
  final CourseLesson? selectedLesson;
  final ValueChanged<CourseLesson> onLessonTap;

  const CourseRecordedChaptersList({
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
    final String courseStatsLabel = '${course.chapters.length} فصل • $totalVideos دروس';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AppText(
                'محتوى الدورة',
                style: font18w700.copyWith(color: const Color(0xFF1E1E2D)),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EEF5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: AppText(
                courseStatsLabel,
                style: font10w700.copyWith(color: AppLightColors.primary),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...course.chapters.asMap().entries.map((entry) {
          final chapter = entry.value;
          int totalChapterSeconds = chapter.videos.fold(0, (sum, video) => sum + video.durationMinutes);
          int totalChapterMinutes = totalChapterSeconds ~/ 60;
          String subtitle = '${chapter.videos.length} دروس • $totalChapterMinutes دقيقة';

          return CourseChapterTile(
            chapter: chapter,
            index: entry.key + 1,
            isEnrolled: course.isEnrolled,
            course: course,
            showActionButtons: false,
            showLessonStatuses: true,
            subtitle: subtitle,
            backgroundColor: Colors.white,
            headerBackgroundColor: const Color(0xFFF6EEF5),
            border: Border.all(
              color: AppLightColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: const [],
            selectedLessonId: selectedLesson?.id,
            onLessonTap: onLessonTap,
          );
        }),
      ],
    );
  }
}

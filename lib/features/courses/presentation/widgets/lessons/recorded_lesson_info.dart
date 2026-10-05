import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_player_placeholder.dart';

/// Video player + current lesson title, description, and tags.
class RecordedLessonInfo extends StatelessWidget {
  final String? imageUrl;
  final String lessonTitle;
  final String lessonDescription;
  final String subjectTag;
  final String instructorName;

  const RecordedLessonInfo({
    super.key,
    required this.imageUrl,
    required this.lessonTitle,
    required this.lessonDescription,
    required this.subjectTag,
    required this.instructorName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CourseVideoPlayerPlaceholder(imageUrl: imageUrl ?? ''),
        SizedBox(height: 20.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EEF5),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: AppText('الدرس الحالي •', style: font12w700.copyWith(color: AppLightColors.primary)),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        AppText(lessonTitle, style: font22w700.copyWith(color: const Color(0xFF1E1E2D)), maxLines: 2),
        SizedBox(height: 12.h),
        AppText(
          lessonDescription,
          style: font14w400.copyWith(color: const Color(0xFF6B7280), height: 1.6),
          maxLines: 4,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            AppText(subjectTag, style: font12w500.copyWith(color: const Color(0xFF6B7280))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Container(
                width: 4.w, height: 4.w,
                decoration: const BoxDecoration(color: Color(0xFFD1D5DB), shape: BoxShape.circle),
              ),
            ),
            AppText(instructorName, style: font12w500.copyWith(color: const Color(0xFF6B7280))),
          ],
        ),
      ],
    );
  }
}

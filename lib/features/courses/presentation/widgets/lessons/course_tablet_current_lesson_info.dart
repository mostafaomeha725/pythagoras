import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';

/// Current lesson info card for Tablet Landscape.
/// Uses explicit typography and paddings without ScreenUtil scaling.
class CourseTabletCurrentLessonInfo extends StatelessWidget {
  final CourseLesson? selectedLesson;
  final CourseDetail course;

  const CourseTabletCurrentLessonInfo({
    super.key,
    required this.selectedLesson,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // "الدرس الحالي" Badge
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF4FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AppText(
                  'الدرس الحالي •',
                  style: font12w700.copyWith(
                    color: AppLightColors.primary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Lesson Title
          AppText(
            selectedLesson?.title ?? 'اختر درساً للبدء',
            style: font20w700.copyWith(
              color: const Color(0xFF1E1E2D),
              fontSize: 18,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 8),

          // Description
          if ((selectedLesson?.description ?? course.description ?? '')
              .isNotEmpty) ...[
            AppText(
              selectedLesson?.description ?? course.description ?? '',
              style: font14w400.copyWith(
                color: const Color(0xFF6B7280),
                fontSize: 13,
                height: 1.5,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 14),
          ],

          // Course and Instructor Row
          Row(
            children: [
              Expanded(
                child: AppText(
                  course.title,
                  style: font12w500.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (course.instructor?.name != null &&
                  course.instructor!.name.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD1D5DB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: AppText(
                    course.instructor!.name,
                    style: font12w500.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

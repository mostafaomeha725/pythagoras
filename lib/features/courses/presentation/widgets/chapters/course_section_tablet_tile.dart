import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_asset.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/models/course_section.dart';

/// Section card for Course Sections Grid on Tablet Landscape.
class CourseSectionTabletTile extends StatelessWidget {
  final CourseSection section;
  final CourseDetail course;
  final int? selectedChapterId;
  final double titleFontSize;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const CourseSectionTabletTile({
    super.key,
    required this.section,
    required this.course,
    this.selectedChapterId,
    this.titleFontSize = 16,
    this.padding,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return BounceIt(
      onPressed: () {
        if (section.label == 'الدروس المسجلة') {
          context.push(
            Routes.courseRecordedLessonsScreen,
            extra: {'course': course, 'selectedChapterId': selectedChapterId},
          );
        } else if (section.label == 'الحصص الأونلاين') {
          context.push(Routes.courseOnlineLessonsScreen, extra: course);
        } else if (section.label == 'الإمتحانات والواجبات') {
          context.push(Routes.courseExamsScreen, extra: course);
        } else if (section.label == 'الموارد') {
          context.push(Routes.courseResourcesScreen, extra: course);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppLightColors.primary, Color(0xFF9C2A7A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppLightColors.primary.withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Section Illustration Image
            Expanded(
              child: Center(
                child: AppAsset(
                  assetName: section.assetPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Section Title
            AppText(
              section.label,
              style: font16w700.copyWith(
                color: Colors.white,
                fontSize: titleFontSize,
              ),
              alignment: AlignmentDirectional.center,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

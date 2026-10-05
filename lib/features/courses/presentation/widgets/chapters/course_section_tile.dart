import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_asset.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/models/course_section.dart';

class CourseSectionTile extends StatelessWidget {
  final CourseSection section;
  final CourseDetail course;
  final int? selectedChapterId;

  const CourseSectionTile({
    super.key,
    required this.section,
    required this.course,
    this.selectedChapterId,
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
          gradient: LinearGradient(
            colors: [AppLightColors.primary, const Color(0xFF9C2A7A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppLightColors.primary.withValues(alpha: 0.3),
              blurRadius: 14.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon/Image
            AppAsset(
              assetName: section.assetPath,
              width: 116.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16.h),
            AppText(
              section.label,
              style: font14w700.copyWith(color: Colors.white),
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

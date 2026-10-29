import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_chapter_tile.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_header.dart';

class CourseDetailScreenBody extends StatelessWidget {
  final CourseDetail course;
  final int? restoreChapterId;
  final void Function(int chapterId, bool isExpanded)?
  onChapterExpansionChanged;

  const CourseDetailScreenBody({
    super.key,
    required this.course,
    this.restoreChapterId,
    this.onChapterExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20.h),

          // Video + Meta + Description
          CourseDetailHeader(course: course),

          SizedBox(height: 28.h),

          // Curriculum label
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: AppLightColors.primary,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: AppText(
              'المنهج الدراسي',
              style: font16w700.copyWith(color: Colors.white),
              alignment: AlignmentDirectional.center,
            ),
          ),

          SizedBox(height: 16.h),

          // Chapters
          ...course.chapters.asMap().entries.map((entry) {
            return CourseChapterTile(
              chapter: entry.value,
              index: entry.key + 1,
              isEnrolled: course.isEnrolled,
              course: course,
              showRestoreButton: entry.value.id == restoreChapterId,
              onExpansionChanged: onChapterExpansionChanged,
            );
          }),
        ],
      ),
    );
  }
}

class CourseDetailBodyRegion extends StatelessWidget {
  final Widget child;

  const CourseDetailBodyRegion({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return Flexible(fit: FlexFit.loose, child: child);
    }
    return Expanded(child: child);
  }
}

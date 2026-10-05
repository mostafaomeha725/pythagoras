import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/models/course_section.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_section_tile.dart';

class CourseSectionsScreenBody extends StatelessWidget {
  final CourseDetail course;
  final int? selectedChapterId;
  const CourseSectionsScreenBody({
    super.key,
    required this.course,
    this.selectedChapterId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppLightColors.primary, const Color(0xFF9C2A7A)],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppLightColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        course.title,
                        style: font16w700.copyWith(color: Colors.white),
                        maxLines: 2,
                      ),
                      SizedBox(height: 6.h),
                      AppText(
                        'اختر القسم الذي تريد متابعته',
                        style: font12w500.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
              ],
            ),
          ),

          // // Subtitle
          // AppText(
          //   'اختر القسم الذي تريد متابعته',
          //   style: font14w400.copyWith(color: const Color(0xFF9CA3AF)),
          //   alignment: AlignmentDirectional.center,
          // ),
          SizedBox(height: 32.h),

          // 2×2 Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              physics: const NeverScrollableScrollPhysics(),
              children: CourseSection.defaultSections
                  .map(
                    (s) => CourseSectionTile(
                      section: s,
                      course: course,
                      selectedChapterId: selectedChapterId,
                    ),
                  )
                  .toList(),
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

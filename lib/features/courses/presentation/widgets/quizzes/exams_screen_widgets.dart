import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Empty state shown when there are no upcoming tasks in CourseExamsScreenBody.
class ExamsEmptyUpcomingState extends StatelessWidget {
  const ExamsEmptyUpcomingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: const BoxDecoration(color: Color(0xFFF9FAFB), shape: BoxShape.circle),
              child: Icon(Icons.assignment_turned_in_outlined, color: const Color(0xFFD1D5DB), size: 36.w),
            ),
            SizedBox(height: 20.h),
            AppText('لا توجد مهام قادمة',
                style: font16w700.copyWith(color: const Color(0xFF374151)),
                alignment: AlignmentDirectional.center),
            SizedBox(height: 4.h),
            AppText('أنت على اطلاع دائم بجميع مهامك!',
                style: font12w500.copyWith(color: const Color(0xFF9CA3AF)),
                textAlign: TextAlign.center,
                alignment: AlignmentDirectional.center),
          ],
        ),
      ),
    );
  }
}

/// Section header row (title + pill) reused in CourseExamsScreenBody.
class ExamsSectionHeader extends StatelessWidget {
  final String title;
  final String pillText;

  const ExamsSectionHeader({super.key, required this.title, required this.pillText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(title, style: font20w700.copyWith(color: const Color(0xFF1E1E2D))),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF4FA),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: AppText(pillText, style: font12w700.copyWith(color: const Color(0xFF832561))),
        ),
      ],
    );
  }
}

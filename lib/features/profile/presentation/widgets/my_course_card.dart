import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/profile/domain/entities/my_course_enrollment.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_course_action_button.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_course_card_header.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_course_congrats_badge.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_course_progress_row.dart';

class MyCourseCard extends StatelessWidget {
  final MyCourseEnrollment enrollment;

  const MyCourseCard({super.key, required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = enrollment.progress >= 100;
    final int progressInt = enrollment.progress;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFEDEDED), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyCourseCardHeader(enrollment: enrollment),
          SizedBox(height: 20.h),
          MyCourseProgressRow(progressInt: progressInt),
          SizedBox(height: 16.h),
          if (isCompleted) ...[
            const MyCourseCongratsBadge(),
            SizedBox(height: 12.h),
          ],
          MyCourseActionButton(enrollment: enrollment),
        ],
      ),
    );
  }
}

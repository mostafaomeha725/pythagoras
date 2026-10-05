import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/assignment_submission.dart';
import 'package:pythagoras/core/utils/date_formatter.dart';
import 'package:pythagoras/core/utils/url_launcher_helper.dart';

class SubmissionItem extends StatelessWidget {
  final AssignmentSubmission submission;

  const SubmissionItem({super.key, required this.submission});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormatter.formatYMD(submission.submittedAt);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: date + score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 13.sp, color: const Color(0xFF9CA3AF)),
                  SizedBox(width: 4.w),
                  AppText(dateStr, style: font12w500.copyWith(color: const Color(0xFF9CA3AF))),
                ],
              ),
              if (submission.pointsAwarded != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: AppText(
                    '${submission.pointsAwarded} درجة',
                    style: font12w700.copyWith(color: const Color(0xFF15803D)),
                  ),
                ),
            ],
          ),

          if (submission.notes != null && submission.notes!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            AppText(
              submission.notes!,
              style: font13w500.copyWith(color: const Color(0xFF374151)),
              maxLines: 3,
            ),
          ],

          if (submission.feedback != null && submission.feedback!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppLightColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.mark_chat_read_outlined, size: 14.sp, color: AppLightColors.primary),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: AppText(
                      submission.feedback!,
                      style: font12w500.copyWith(color: AppLightColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (submission.submittedFiles.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: submission.submittedFiles.map((f) {
                return GestureDetector(
                  onTap: () => UrlLauncherHelper.openUrl(f.url),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file, size: 13.sp, color: AppLightColors.primary),
                        SizedBox(width: 4.w),
                        AppText(
                          f.name.length > 20 ? '${f.name.substring(0, 18)}...' : f.name,
                          style: font12w500.copyWith(color: AppLightColors.primary),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

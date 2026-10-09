import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/core/services/native_download_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_sheet.dart';
import 'package:pythagoras/core/utils/date_formatter.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/assignment_card_file_badge.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/assignment_status_pill.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/course_assignment_view_button.dart';

class CourseAssignmentCard extends StatelessWidget {
  final CourseAssignment assignment;
  final VoidCallback? onSubmitted;

  const CourseAssignmentCard({
    super.key,
    required this.assignment,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final fileUrl = assignment.assignmentFile?.url;
    final fileName = assignment.assignmentFile?.name;

    String fileExt = 'FILE';
    if (fileName != null && fileName.contains('.')) {
      fileExt = fileName.split('.').last.toUpperCase();
      if (fileExt.length > 4) {
        fileExt = fileExt.substring(0, 4);
      }
    }
    bool isLate = false;
    if (assignment.dueDate != null) {
      try {
        final dueDate = DateTime.parse(assignment.dueDate!);
        if (dueDate.isBefore(DateTime.now())) {
          isLate = true;
        }
      } catch (_) {}
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0x05000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // File icon badge (right in RTL)
              AssignmentCardFileBadge(fileExt: fileExt),
              // Title + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      assignment.title,
                      style: font16w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                      ),
                      maxLines: 2,
                    ),
                    if (assignment.description != null) ...[
                      SizedBox(height: 6.h),
                      AppText(
                        assignment.description!,
                        style: font12w500.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
              if (assignment.dueDate != null) ...[
                SizedBox(width: 8.w),
                AssignmentStatusPill(isLate: isLate),
              ],
            ],
          ),
          SizedBox(height: 16.h),

          // Meta (date)
          if (assignment.dueDate != null) ...[
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14.sp,
                  color: const Color(0xFF9CA3AF),
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: AppText(
                    'التسليم: ${DateFormatter.formatYMD(assignment.dueDate!)}',
                    style: font12w500.copyWith(color: const Color(0xFF6B7280)),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],

          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // View button
              if (fileUrl != null) ...[
                CourseAssignmentViewButton(assignment: assignment),
                SizedBox(width: 8.w),
              ],
              // Download button
              if (fileUrl != null) ...[
                BounceIt(
                  onPressed: () async {
                    EasyLoading.show(status: 'جاري التحميل...');
                    final fileName = fileUrl.split('/').last.split('?').first;
                    final success = await NativeDownloadService().enqueueDownload(
                      url: fileUrl,
                      title: assignment.title,
                      fileName: fileName.isNotEmpty ? fileName : 'assignment_file',
                    );
                    EasyLoading.dismiss();
                    if (success && !kIsWeb && Platform.isIOS) {
                      EasyLoading.showSuccess('تم الحفظ بنجاح');
                    } else if (success) {
                      EasyLoading.showSuccess('تم البدء في تحميل الملف');
                    } else {
                      EasyLoading.showError('فشل في بدء التحميل');
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          'تحميل',
                          style: font13w700.copyWith(
                            color: const Color(0xFF374151),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.download_outlined,
                          color: const Color(0xFF374151),
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              // Submit button
              BounceIt(
                onPressed: () => SubmitAssignmentSheet.show(
                  context,
                  assignmentId: assignment.id,
                  assignmentTitle: assignment.title,
                  onSubmitted: onSubmitted,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppLightColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.upload_file_outlined,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      AppText(
                        'تسليم',
                        style: font13w700.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

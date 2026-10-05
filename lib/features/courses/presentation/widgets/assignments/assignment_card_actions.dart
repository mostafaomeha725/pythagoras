import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/utils/url_launcher_helper.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_sheet.dart';

/// Row of action buttons: "Download" (conditional) + "Submit" for assignment cards.
class AssignmentCardActions extends StatelessWidget {
  final String? fileUrl;
  final int assignmentId;
  final String assignmentTitle;

  final VoidCallback? onSubmitted;

  const AssignmentCardActions({
    super.key,
    required this.fileUrl,
    required this.assignmentId,
    required this.assignmentTitle,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (fileUrl != null) ...[
          BounceIt(
            onPressed: () => UrlLauncherHelper.openUrl(fileUrl!),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText('تحميل', style: font13w700.copyWith(color: const Color(0xFF374151))),
                  SizedBox(width: 6.w),
                  Icon(Icons.download_outlined, color: const Color(0xFF374151), size: 16.sp),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        BounceIt(
          onPressed: () => SubmitAssignmentSheet.show(
            context,
            assignmentId: assignmentId,
            assignmentTitle: assignmentTitle,
            onSubmitted: onSubmitted,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppLightColors.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.upload_file_outlined, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                AppText('تسليم', style: font13w700.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

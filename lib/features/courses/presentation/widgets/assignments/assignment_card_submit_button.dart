import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_sheet.dart';

class AssignmentCardSubmitButton extends StatelessWidget {
  final int assignmentId;
  final String assignmentTitle;
  final VoidCallback? onSubmitted;

  const AssignmentCardSubmitButton({
    super.key,
    required this.assignmentId,
    required this.assignmentTitle,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return BounceIt(
      onPressed: () => SubmitAssignmentSheet.show(
        context,
        assignmentId: assignmentId,
        assignmentTitle: assignmentTitle,
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
    );
  }
}

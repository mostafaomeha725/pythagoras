import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/assignment_card_download_button.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/assignment_card_submit_button.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/course_assignment_view_button.dart';

/// Row of action buttons: "View" + "Download" (conditional) + "Submit" for assignment cards.
class AssignmentCardActions extends StatelessWidget {
  final CourseAssignment assignment;
  final VoidCallback? onSubmitted;

  const AssignmentCardActions({
    super.key,
    required this.assignment,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final fileUrl = assignment.assignmentFile?.url;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (fileUrl != null) ...[
          CourseAssignmentViewButton(assignment: assignment),
          SizedBox(width: 8.w),
          AssignmentCardDownloadButton(
            fileUrl: fileUrl,
            title: assignment.title,
          ),
          SizedBox(width: 8.w),
        ],
        AssignmentCardSubmitButton(
          assignmentId: assignment.id,
          assignmentTitle: assignment.title,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}

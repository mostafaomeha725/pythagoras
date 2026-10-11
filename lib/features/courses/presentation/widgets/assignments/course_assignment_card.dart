import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/assignment_card_actions.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/assignment_card_due_date.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/assignment_card_header.dart';

class CourseAssignmentCard extends StatelessWidget {
  final CourseAssignment assignment;
  final VoidCallback? onSubmitted;

  const CourseAssignmentCard({
    super.key,
    required this.assignment,
    this.onSubmitted,
  });

  String _extractFileExtension(String? fileName) {
    if (fileName != null && fileName.contains('.')) {
      final ext = fileName.split('.').last.toUpperCase();
      return ext.length > 4 ? ext.substring(0, 4) : ext;
    }
    return 'FILE';
  }

  bool _checkIsLate(String? dueDateStr) {
    if (dueDateStr == null) return false;
    try {
      final dueDate = DateTime.parse(dueDateStr);
      return dueDate.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = assignment.assignmentFile?.name;
    final fileExt = _extractFileExtension(fileName);
    final isLate = _checkIsLate(assignment.dueDate);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AssignmentCardHeader(
            fileExt: fileExt,
            title: assignment.title,
            description: assignment.description,
            showStatus: assignment.dueDate != null,
            isLate: isLate,
          ),
          SizedBox(height: 16.h),
          if (assignment.dueDate != null) ...[
            AssignmentCardDueDate(dueDate: assignment.dueDate!),
            SizedBox(height: 12.h),
          ],
          AssignmentCardActions(
            assignment: assignment,
            onSubmitted: onSubmitted,
          ),
        ],
      ),
    );
  }
}

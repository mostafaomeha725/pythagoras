import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/assignment_card_file_badge.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/assignment_status_pill.dart';

/// Top header row of [CourseAssignmentCard]:
/// file badge | title + description | status pill (optional).
class AssignmentCardHeader extends StatelessWidget {
  final String fileExt;
  final String title;
  final String? description;
  final bool showStatus;
  final bool isLate;

  const AssignmentCardHeader({
    super.key,
    required this.fileExt,
    required this.title,
    this.description,
    required this.showStatus,
    required this.isLate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AssignmentCardFileBadge(fileExt: fileExt),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                style: font16w700.copyWith(color: const Color(0xFF1E1E2D)),
                maxLines: 2,
              ),
              if (description != null) ...[
                SizedBox(height: 6.h),
                AppText(
                  description!,
                  style: font12w500.copyWith(color: const Color(0xFF6B7280)),
                  maxLines: 2,
                ),
              ],
            ],
          ),
        ),
        if (showStatus) ...[
          SizedBox(width: 8.w),
          AssignmentStatusPill(isLate: isLate),
        ],
      ],
    );
  }
}

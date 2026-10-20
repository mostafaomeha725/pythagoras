import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/date_formatter.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/course_tablet_assignment_action_buttons.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_sheet.dart';

/// Upcoming Assignment Card optimized for Tablet Landscape.
/// Uses explicit typography and paddings to prevent ScreenUtil scaling blowups.
class CourseTabletAssignmentCard extends StatelessWidget {
  final CourseAssignment assignment;
  final VoidCallback? onSubmitted;

  const CourseTabletAssignmentCard({
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
    final fileUrl = assignment.assignmentFile?.url;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
          // Header Row: File Badge + Title/Desc + Status Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  fileExt,
                  style: font12w700.copyWith(
                    color: const Color(0xFF2563EB),
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      assignment.title,
                      style: font16w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                        fontSize: 15,
                      ),
                      maxLines: 2,
                    ),
                    if (assignment.description != null &&
                        assignment.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      AppText(
                        assignment.description!,
                        style: font12w500.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
              if (assignment.dueDate != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLate
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText(
                    isLate ? 'متأخر' : 'متاح',
                    style: font12w700.copyWith(
                      color: isLate
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF059669),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (assignment.dueDate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 5),
                AppText(
                  'موعد التسليم: ${DateFormatter.format(assignment.dueDate)}',
                  style: font12w500.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (fileUrl != null) ...[
                CourseTabletAssignmentActionButtons(assignment: assignment),
                const SizedBox(width: 8),
              ],
              BounceIt(
                onPressed: () => SubmitAssignmentSheet.show(
                  context,
                  assignmentId: assignment.id,
                  assignmentTitle: assignment.title,
                  onSubmitted: onSubmitted,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppLightColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.upload_file_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      AppText(
                        'تسليم',
                        style: font13w700.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
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

import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/date_formatter.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/assignment_submission.dart';
import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';

/// Completed Assignment Card optimized for Tablet Landscape.
/// Uses explicit typography and paddings to prevent ScreenUtil scaling blowups.
class CourseTabletTaskCompletedCard extends StatelessWidget {
  final CourseAssignment assignment;
  final AssignmentSubmission submission;

  const CourseTabletTaskCompletedCard({
    super.key,
    required this.assignment,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFailed = submission.pointsAwarded != null &&
        submission.pointsAwarded! < (assignment.maxPoints / 2);

    final Color primaryColor =
        isFailed ? const Color(0xFFEF4444) : const Color(0xFF059669);
    final Color bgColor =
        isFailed ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Right Side: Badge + Icon + Title
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        'واجب',
                        style: font10w700.copyWith(
                          color: const Color(0xFF2563EB),
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFailed
                            ? Icons.cancel_outlined
                            : Icons.check_circle_outline_rounded,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        assignment.title,
                        style: font14w700.copyWith(
                          color: const Color(0xFF1F2937),
                          fontSize: 14,
                          height: 1.3,
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
                            fontSize: 11,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Left Side: Score Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppText(
                  'الدرجة:',
                  style: font12w700.copyWith(
                    color: primaryColor,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                AppText(
                  submission.pointsAwarded != null
                      ? '${submission.pointsAwarded}/${assignment.maxPoints}'
                      : 'قيد المراجعة',
                  style: font14w700.copyWith(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                AppText(
                  DateFormatter.format(submission.submittedAt),
                  style: font10w500.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

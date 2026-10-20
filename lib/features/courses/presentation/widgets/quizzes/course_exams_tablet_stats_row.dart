import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Tablet landscape stats row for [CourseExamsScreen].
/// Features balanced cards for average score and upcoming tasks.
class CourseExamsTabletStatsRow extends StatelessWidget {
  final String averageScore;
  final int upcomingTasksCount;

  const CourseExamsTabletStatsRow({
    super.key,
    required this.averageScore,
    required this.upcomingTasksCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Average Grade Box
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF4FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3D4E8), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        averageScore,
                        style: font24w700.copyWith(
                          color: const Color(0xFF832561),
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        'متوسط الدرجات',
                        style: font12w500.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF832561).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.military_tech_outlined,
                      color: Color(0xFF832561),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Upcoming Tasks Box
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8EA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        upcomingTasksCount.toString(),
                        style: font24w700.copyWith(
                          color: const Color(0xFFB45309),
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        'مهام قادمة',
                        style: font12w500.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB45309).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.assignment_outlined,
                      color: Color(0xFFB45309),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

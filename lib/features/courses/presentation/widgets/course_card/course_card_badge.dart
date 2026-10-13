import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_badge_type.dart';

/// Reusable status badge pill for course cards and course detail headers.
class CourseCardBadge extends StatelessWidget {
  final CourseBadgeType badgeType;

  const CourseCardBadge({super.key, required this.badgeType});

  @override
  Widget build(BuildContext context) {
    if (badgeType == CourseBadgeType.none) {
      return const SizedBox.shrink();
    }

    final _BadgeConfig config = _resolveConfig(badgeType);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: config.backgroundColor.withValues(alpha: 0.3),
            blurRadius: 8.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, color: config.foregroundColor, size: 14.sp),
          SizedBox(width: 4.w),
          AppText(
            config.label,
            style: font12w700.copyWith(color: config.foregroundColor),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _resolveConfig(CourseBadgeType type) {
    switch (type) {
      case CourseBadgeType.courseEnrolled:
        return const _BadgeConfig(
          label: 'مسجل',
          icon: Icons.check_circle_rounded,
          backgroundColor: Color(0xFF059669),
          foregroundColor: Colors.white,
        );
      case CourseBadgeType.coursePending:
        return const _BadgeConfig(
          label: 'قيد الانتظار',
          icon: Icons.pending_actions_rounded,
          backgroundColor: Color(0xFFD97706),
          foregroundColor: Colors.white,
        );
      case CourseBadgeType.chapterEnrolled:
        return const _BadgeConfig(
          label: 'حصة مسجلة',
          icon: Icons.check_circle_rounded,
          backgroundColor: Color(0xFF059669),
          foregroundColor: Colors.white,
        );
      case CourseBadgeType.chapterPending:
        return const _BadgeConfig(
          label: 'حصة قيد الانتظار',
          icon: Icons.pending_actions_rounded,
          backgroundColor: Color(0xFFCA8A04), // Distinct yellow / gold
          foregroundColor: Colors.white,
        );
      case CourseBadgeType.none:
        return const _BadgeConfig(
          label: '',
          icon: Icons.info,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const _BadgeConfig({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });
}

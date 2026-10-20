import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_image.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/domain/entities/my_course_enrollment.dart';

/// Top cover image and status badges for MyCourseTabletCard.
class MyCourseTabletCardCover extends StatelessWidget {
  final MyCourseEnrollment enrollment;

  const MyCourseTabletCardCover({super.key, required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = enrollment.progress >= 100;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14.8)),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: AppImage(
              imageUrl: enrollment.course.coverUrl ?? '',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Status Pill (Top Right in RTL)
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: enrollment.status == 'in_progress'
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF64748B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                AppText(
                  enrollment.status == 'in_progress' ? 'نشط' : 'منتهي',
                  style: font12w700.copyWith(
                    color: enrollment.status == 'in_progress'
                        ? const Color(0xFF15803D)
                        : const Color(0xFF475569),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Completion Trophy Badge (Top Left in RTL)
        if (isCompleted)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    size: 14,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 4),
                  AppText(
                    'مكتمل',
                    style: font12w700.copyWith(
                      color: const Color(0xFFB45309),
                      fontSize: 11,
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

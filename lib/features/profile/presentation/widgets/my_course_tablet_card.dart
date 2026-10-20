import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/domain/entities/my_course_enrollment.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_course_tablet_card_cover.dart';

/// Enrolled Course Card tailored specifically for Tablet Landscape.
/// Uses fixed pixel sizing and 16:9 imagery for balanced presentation.
class MyCourseTabletCard extends StatelessWidget {
  final MyCourseEnrollment enrollment;

  const MyCourseTabletCard({super.key, required this.enrollment});

  void _navigateToCourse(BuildContext context) {
    context.push(
      Routes.courseDetailScreen,
      extra: {
        'id': enrollment.course.id,
        'title': enrollment.course.title,
        'isEnrolled': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = enrollment.progress >= 100;
    final int progress = enrollment.progress;

    return BounceIt(
      onPressed: () => _navigateToCourse(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Cover Image & Status Badges
            MyCourseTabletCardCover(enrollment: enrollment),

            // Card Body Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Title
                  AppText(
                    enrollment.course.title,
                    style: font16w700.copyWith(
                      color: const Color(0xFF1E1E2D),
                      fontSize: 15,
                      height: 1.35,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 6),

                  // Instructor Name
                  if (enrollment.course.instructor?.name != null)
                    AppText(
                      enrollment.course.instructor!.name,
                      style: font12w500.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 12.5,
                      ),
                      maxLines: 1,
                    ),

                  const SizedBox(height: 14),

                  // Progress Bar & Percentage Row
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppLightColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        isCompleted ? 'أتممت الدورة بنجاح' : 'مستمر بالدراسة',
                        style: font12w500.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 11.5,
                        ),
                      ),
                      AppText(
                        '$progress% مكتمل',
                        style: font14w600.copyWith(
                          color: AppLightColors.primary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Action Button: Resume Course
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppLightColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_circle_outline_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        AppText(
                          'متابعة الدورة',
                          style: font14w600.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          alignment: AlignmentDirectional.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

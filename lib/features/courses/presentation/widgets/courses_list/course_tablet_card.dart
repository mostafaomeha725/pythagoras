import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_image.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course.dart';
import 'package:pythagoras/features/courses/domain/entities/course_badge_type.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_card/course_card_badge.dart';

/// Course Card explicitly styled for Tablet Landscape.
/// Uses fixed pixel metrics to prevent ScreenUtil enlargement.
class CourseTabletCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const CourseTabletCard({super.key, required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final badge = course.badgeType;

    return BounceIt(
      onPressed: onTap ?? () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Course Image & Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: AspectRatio(
                    aspectRatio: 2.1,
                    child: AppImage(
                      imageUrl: course.imageUrl ?? '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (badge != CourseBadgeType.none)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CourseCardBadge(
                      badgeType: badge,
                      tabletLandscape: true,
                    ),
                  ),
              ],
            ),

            // Course Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: isIOS
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AppText(
                            course.title,
                            style: font16w700.copyWith(
                              color: const Color(0xFF1E1E2D),
                              fontSize: 15.5,
                              height: 1.35,
                            ),
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFCEEFA),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_forward,
                              color: AppLightColors.primary,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          course.title,
                          style: font16w700.copyWith(
                            color: const Color(0xFF1E1E2D),
                            fontSize: 15.5,
                            height: 1.35,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                AppText(
                                  course.price.toStringAsFixed(2),
                                  style: font16w700.copyWith(
                                    color: AppLightColors.primary,
                                    fontSize: 15.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                AppText(
                                  course.currencyLabel ?? "دينار كويتي",
                                  style: font14w600.copyWith(
                                    color: AppLightColors.primary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFCEEFA),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: AppLightColors.primary,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/widgets/app_image.dart';
import 'package:pythagoras/features/courses/domain/entities/course_badge_type.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_card/course_card_badge.dart';

class CourseDetailImage extends StatelessWidget {
  final CourseDetail course;
  final bool tabletLandscape;

  const CourseDetailImage({
    super.key,
    required this.course,
    this.tabletLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(tabletLandscape ? 16 : 16.r),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 2.0,
            child: AppImage(
              imageUrl: course.imageUrl ?? '',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          if (course.badgeType != CourseBadgeType.none)
            Positioned(
              top: tabletLandscape ? 12 : 12.h,
              right: tabletLandscape ? 12 : 12.w,
              child: CourseCardBadge(
                badgeType: course.badgeType,
                tabletLandscape: tabletLandscape,
              ),
            ),
        ],
      ),
    );
  }
}

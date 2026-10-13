import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/widgets/app_image.dart';
import 'package:pythagoras/features/courses/domain/entities/course_badge_type.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_card/course_card_badge.dart';

class CourseDetailImage extends StatelessWidget {
  final CourseDetail course;

  const CourseDetailImage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
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
              top: 12.h,
              right: 12.w,
              child: CourseCardBadge(badgeType: course.badgeType),
            ),
        ],
      ),
    );
  }
}

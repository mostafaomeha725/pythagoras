import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/widgets/app_image.dart';
import 'package:pythagoras/features/courses/domain/entities/course_badge_type.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_card/course_card_badge.dart';

class CourseCardImage extends StatelessWidget {
  final String? imageUrl;
  final CourseBadgeType? badgeType;
  final bool isEnrolled;
  final String? requestStatus;
  final String? chapterRequest;

  const CourseCardImage({
    super.key,
    required this.imageUrl,
    this.badgeType,
    this.isEnrolled = false,
    this.requestStatus,
    this.chapterRequest,
  });

  CourseBadgeType get _effectiveBadge {
    if (badgeType != null) {
      return badgeType!;
    }
    final req = requestStatus?.trim().toLowerCase();
    final chap = chapterRequest?.trim().toLowerCase();

    if (isEnrolled || req == 'accepted') {
      return CourseBadgeType.courseEnrolled;
    }
    if (req == 'pending') {
      return CourseBadgeType.coursePending;
    }
    if (chap == 'accepted') {
      return CourseBadgeType.chapterEnrolled;
    }
    if (chap == 'pending') {
      return CourseBadgeType.chapterPending;
    }
    return CourseBadgeType.none;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBadge = _effectiveBadge;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
          child: AspectRatio(
            aspectRatio: 2.0,
            child: AppImage(
              imageUrl: imageUrl ?? '',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (effectiveBadge != CourseBadgeType.none)
          Positioned(
            top: 12.h,
            right: 12.w,
            child: CourseCardBadge(badgeType: effectiveBadge),
          ),
      ],
    );
  }
}

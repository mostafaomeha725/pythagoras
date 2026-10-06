import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_meta_chip.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_star_row.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';

class CourseDetailInfo extends StatelessWidget {
  final CourseDetail course;

  const CourseDetailInfo({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        AppText(
          course.title,
          style: font22w700.copyWith(color: const Color(0xFF1E1E2D)),
          maxLines: 3,
        ),
        SizedBox(height: 16.h),

        // Meta chips
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          children: [
            CourseMetaChip(
              icon: Icons.person_outline,
              label: course.instructor?.name ?? '',
            ),
            GestureDetector(
              onTap: () {
                context.push(
                  Routes.courseReviewsScreen,
                  extra: {
                    'courseId': course.id,
                    'courseTitle': course.title,
                  },
                );
              },
              child: CourseStarRow(rating: course.rating.toDouble()),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Price
        Row(
          children: [
            AppText(
              'سعر الدورة: ',
              style: font14w600.copyWith(color: const Color(0xFF6B7280)),
            ),
            AppText(
              '${course.price} ${course.currencyLabel}',
              style: font16w700.copyWith(color: AppLightColors.primary),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // Description
        AppText(
          'ما الذي ستتعلمه في هذه الدورة',
          style: font16w700.copyWith(color: const Color(0xFF1E1E2D)),
        ),
        SizedBox(height: 8.h),
        AppText(
          course.description ?? '',
          style: font14w400.copyWith(
            color: const Color(0xFF6B7280),
            height: 1.7,
          ),
          maxLines: 10,
        ),
      ],
    );
  }
}

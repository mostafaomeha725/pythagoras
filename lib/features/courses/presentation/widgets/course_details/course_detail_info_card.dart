import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_image.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_meta_chip.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_star_row.dart';

/// Left card for Course Details on Tablet Landscape:
/// Course Image, Title, Rating/Instructor Chips, Price, and Description.
class CourseDetailInfoCard extends StatelessWidget {
  final CourseDetail course;

  const CourseDetailInfoCard({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Thumbnail / Video
          CourseDetailImage(
            course: course,
            tabletLandscape: true,
          ),

          const SizedBox(height: 20),

          // Course Title
          AppText(
            course.title,
            style: font22w700.copyWith(
              color: const Color(0xFF1E1E2D),
              fontSize: 24,
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 14),

          // Meta Chips & Rating Row
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (course.instructor?.name != null &&
                  course.instructor!.name.isNotEmpty)
                CourseMetaChip(
                  icon: Icons.person_outline,
                  label: course.instructor!.name,
                  tabletLandscape: true,
                ),
              GestureDetector(
                onTap: () async {
                  await context.push(
                    Routes.courseReviewsScreen,
                    extra: {'courseId': course.id, 'courseTitle': course.title},
                  );
                  if (context.mounted) {
                    context.read<CourseDetailsCubit>().fetchCourseDetails(
                          course.id,
                        );
                    try {
                      context.read<CoursesListCubit>().fetchCourses();
                    } catch (_) {}
                  }
                },
                child: CourseStarRow(
                  rating: course.rating.toDouble(),
                  tabletLandscape: true,
                ),
              ),
            ],
          ),

          // Price (Hidden on iOS)
          if (!isIOS) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                AppText(
                  'سعر الدورة: ',
                  style: font14w600.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 15,
                  ),
                ),
                AppText(
                  '${course.price} ${course.currencyLabel}',
                  style: font16w700.copyWith(
                    color: AppLightColors.primary,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 18),

          // Section Title: "ما الذي ستتعلمه في هذه الدورة"
          AppText(
            'ما الذي ستتعلمه في هذه الدورة',
            style: font16w700.copyWith(
              color: const Color(0xFF1E1E2D),
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 8),

          // Description Body
          AppText(
            course.description ?? '',
            style: font14w400.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.7,
              fontSize: 15,
            ),
            maxLines: 20,
          ),
        ],
      ),
    );
  }
}

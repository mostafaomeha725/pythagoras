import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_cubit.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';
import 'package:pythagoras/features/courses/presentation/widgets/apple_iap_purchase_section.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_curriculum_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_info_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_action_button.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_cubit.dart';

/// Dedicated Tablet Landscape layout for [CourseDetailScreen].
/// Features a two-column card layout:
/// - Right Column: Curriculum card (Banner & Chapters)
/// - Left Column: Course info card (Image, Title, Ratings, Description)
/// - Fixed Bottom Action Button: Stays sticky on the screen aligned with the right column.
class CourseDetailTabletLandscape extends StatelessWidget {
  final CourseDetail course;
  final BoxConstraints constraints;

  const CourseDetailTabletLandscape({
    super.key,
    required this.course,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final requestsEnabled = context
        .watch<RemoteConfigCubit>()
        .state
        .courseLessonRequestsEnabled;
    final moveRestoreToRequestSlot =
        Theme.of(context).platform == TargetPlatform.iOS &&
        !course.isEnrolled &&
        !requestsEnabled;
    const horizontalPadding = 20.0;
    final columnWidth =
        (constraints.maxWidth - horizontalPadding * 2 - 20.0) / 2;

    return Stack(
      children: [
        // ── Main Content Area ───────────────────────────────────────
        Positioned.fill(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fixed Top Header: Back Button + Title
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 8.0,
                  ),
                  child: CourseDetailTabletTopBar(),
                ),

                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: 4.0,
                      bottom: 190.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Right Column (Curriculum + Chapters)
                        Expanded(
                          child: CourseDetailCurriculumCard(course: course),
                        ),

                        const SizedBox(width: 20),

                        // Left Column (Image + Title + Rating + Description)
                        Expanded(child: CourseDetailInfoCard(course: course)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Fixed Action Button ("عرض الدورة" / "طلب الدورة") ───────
        // In RTL: positioned at the bottom right, aligned with Curriculum Card
        Positioned(
          bottom: 16,
          right: horizontalPadding,
          width: columnWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppleIapPurchaseSection(
                type: AppleIapProductType.course,
                contentId: course.id,
                appleProductId: course.appleProductId,
                isRequestStatusEligible:
                    course.requestStatus?.trim().toLowerCase() ==
                    'not_requested',
                isEnrolled: course.isEnrolled,
                hasPendingRequest:
                    course.requestStatus?.trim().toLowerCase() == 'pending',
                tabletLandscape: true,
                showRestoreButton: !moveRestoreToRequestSlot,
                onAuthenticated: () {
                  context.read<CourseDetailsCubit>().fetchCourseDetails(
                    course.id,
                  );
                },
              ),
              if (moveRestoreToRequestSlot)
                AppleIapPurchaseSection(
                  key: const ValueKey('course-detail-restore-action-slot'),
                  type: AppleIapProductType.course,
                  contentId: course.id,
                  appleProductId: course.appleProductId,
                  isRequestStatusEligible:
                      course.requestStatus?.trim().toLowerCase() ==
                      'not_requested',
                  isEnrolled: course.isEnrolled,
                  hasPendingRequest:
                      course.requestStatus?.trim().toLowerCase() == 'pending',
                  tabletLandscape: true,
                  showPurchaseButton: false,
                  showRestoreButton: true,
                )
              else
                CourseDetailTabletActionButton(course: course),
            ],
          ),
        ),
      ],
    );
  }
}

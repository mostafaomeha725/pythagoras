import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/date_formatter.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/live_session.dart';
import 'package:pythagoras/features/courses/domain/entities/online_lesson.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_live_sessions/course_live_sessions_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_live_sessions/course_live_sessions_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/course_online_lessons_tablet_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/course_tablet_online_lessons_section.dart';

/// Tablet Landscape layout for [CourseOnlineLessonsScreen].
class CourseOnlineLessonsTabletLandscape extends StatelessWidget {
  final CourseDetail course;

  const CourseOnlineLessonsTabletLandscape({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<CourseLiveSessionsCubit>()..getSessions(course.id),
      child: BlocBuilder<CourseLiveSessionsCubit, CourseLiveSessionsState>(
        builder: (context, state) {
          if (state is CourseLiveSessionsLoading) {
            return const CourseOnlineLessonsTabletShimmer();
          }

          if (state is CourseLiveSessionsError) {
            return NoInternetWidget(
              message: state.message,
              onRetry: () => context
                  .read<CourseLiveSessionsCubit>()
                  .getSessions(course.id),
            );
          }

          List<LiveSession> sessions = [];
          if (state is CourseLiveSessionsLoaded) {
            sessions = state.sessions;
          }

          final now = DateTime.now();
          final liveLessons = <OnlineLesson>[];
          final upcomingLessons = <OnlineLesson>[];

          for (final session in sessions) {
            final isLive = session.scheduledAt.isBefore(
                  now.add(const Duration(minutes: 60)),
                ) &&
                session.scheduledAt.isAfter(
                  now.subtract(const Duration(minutes: 60)),
                );

            String platform = 'منصة خارجية';
            if (session.link.toLowerCase().contains('zoom')) {
              platform = 'Zoom';
            } else if (session.link.toLowerCase().contains('meet.google')) {
              platform = 'Google Meet';
            } else if (session.link.toLowerCase().contains('teams')) {
              platform = 'Microsoft Teams';
            }

            final mapped = OnlineLesson(
              title: session.name,
              subject: session.courseTitle,
              teacherName: '',
              dateString: DateFormatter.formatDateString(
                session.scheduledAtStr,
              ),
              timeString: DateFormatter.formatTimeString(
                session.scheduledAtStr,
              ),
              durationMinutes: 60,
              platform: platform,
              joinUrl: session.link,
              status: isLive
                  ? OnlineLessonStatus.live
                  : OnlineLessonStatus.upcoming,
            );

            if (isLive) {
              liveLessons.add(mapped);
            } else {
              upcomingLessons.add(mapped);
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fixed Top Bar with back button and title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: CourseDetailTabletTopBar(title: 'الحصص الأونلاين'),
              ),

              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Header Section
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  'جدول حصصك',
                                  style: font20w700.copyWith(
                                    color: const Color(0xFF1E1E2D),
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AppText(
                                  'لا تفوّت موعدك القادم',
                                  style: font12w500.copyWith(
                                    color: const Color(0xFF6B7280),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF4FA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppLightColors.primary,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  AppText(
                                    '${sessions.length} حصص',
                                    style: font12w700.copyWith(
                                      color: AppLightColors.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Live Section
                      CourseTabletOnlineLessonsSection(
                        title: 'مباشر الآن',
                        lessons: liveLessons,
                        emptyIcon: Icons.videocam_off_outlined,
                        emptyMessage: 'لا توجد حصص مباشرة حالياً',
                      ),

                      const SizedBox(height: 24),

                      // Upcoming Section
                      CourseTabletOnlineLessonsSection(
                        title: 'الحصص القادمة',
                        lessons: upcomingLessons,
                        emptyIcon: Icons.event_busy_outlined,
                        emptyMessage: 'لا توجد حصص قادمة قريباً',
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

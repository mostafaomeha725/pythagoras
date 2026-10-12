import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/course_online_lessons_header.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/course_online_lessons_section.dart';

import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/online_lesson.dart';
import 'package:pythagoras/features/courses/domain/entities/live_session.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/utils/date_formatter.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_live_sessions/course_live_sessions_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/course_online_lessons_shimmer.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_live_sessions/course_live_sessions_state.dart';

class CourseOnlineLessonsScreenBody extends StatelessWidget {
  final CourseDetail course;

  const CourseOnlineLessonsScreenBody({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<CourseLiveSessionsCubit>()..getSessions(course.id),
      child: BlocBuilder<CourseLiveSessionsCubit, CourseLiveSessionsState>(
        builder: (context, state) {
          if (state is CourseLiveSessionsLoading) {
            return const CourseOnlineLessonsShimmer();
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
            final isLive =
                session.scheduledAt.isBefore(
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

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CourseOnlineLessonsHeader(),
                SizedBox(height: 32.h),

                CourseOnlineLessonsSection(
                  title: 'مباشر الآن',
                  lessons: liveLessons,
                  emptyIcon: Icons.videocam_off_outlined,
                  emptyMessage: 'لا توجد حصص مباشرة حالياً',
                ),
                SizedBox(height: 24.h),

                CourseOnlineLessonsSection(
                  title: 'الحصص القادمة',
                  lessons: upcomingLessons,
                  emptyIcon: Icons.event_busy_outlined,
                  emptyMessage: 'لا توجد حصص قادمة قريباً',
                ),
                SizedBox(height: 40.h),
              ],
            ),
          );
        },
      ),
    );
  }
}

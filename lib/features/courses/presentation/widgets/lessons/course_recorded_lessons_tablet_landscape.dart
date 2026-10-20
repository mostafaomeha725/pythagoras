import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/cubit/chapter_videos/chapter_videos_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_recorded_lessons_tablet_mixin.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_recorded_lessons_tablet_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_tablet_playlist_pane.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_tablet_video_player_pane.dart';

/// Master-Detail Tablet Landscape layout for [CourseRecordedLessonsScreen].
/// Places the Video Player & Details on the right and Curriculum Playlist on the left (in RTL).
class CourseRecordedLessonsTabletLandscape extends StatefulWidget {
  final CourseDetail course;
  final int? selectedChapterId;

  const CourseRecordedLessonsTabletLandscape({
    super.key,
    required this.course,
    this.selectedChapterId,
  });

  @override
  State<CourseRecordedLessonsTabletLandscape> createState() =>
      _CourseRecordedLessonsTabletLandscapeState();
}

class _CourseRecordedLessonsTabletLandscapeState
    extends State<CourseRecordedLessonsTabletLandscape>
    with CourseRecordedLessonsTabletMixin {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChapterVideosCubit, ChapterVideosState>(
      builder: (context, state) {
        if (state is AllChapterVideosLoading || state is ChapterVideosInitial) {
          return const CourseRecordedLessonsTabletShimmer();
        }

        final updatedCourse = getUpdatedCourse();
        syncSelectedLessonWithUpdates();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with back button and screen title
              const CourseDetailTabletTopBar(title: 'الدروس المسجلة'),

              const SizedBox(height: 12),

              // Two-Pane Content: Player & Details (Right) + Playlist (Left)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pane 1: Video Player and Lesson Info (Right Pane in RTL)
                    CourseTabletVideoPlayerPane(
                      course: widget.course,
                      selectedLesson: selectedLesson,
                      updatedCourse: updatedCourse,
                    ),

                    const SizedBox(width: 20),

                    // Pane 2: Curriculum Chapters & Lessons Playlist (Left Pane in RTL)
                    CourseTabletPlaylistPane(
                      course: updatedCourse,
                      selectedLesson: selectedLesson,
                      onLessonTap: (lesson) =>
                          onLessonTap(lesson, updatedCourse),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

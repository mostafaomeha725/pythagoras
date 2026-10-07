import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/cubit/chapter_videos/chapter_videos_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_recorded_current_lesson_info.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_recorded_chapters_list.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_player_placeholder.dart';

import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_recorded_lessons_mixin.dart';

import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_recorded_lessons_shimmer.dart';

class CourseRecordedLessonsScreenBody extends StatefulWidget {
  final CourseDetail course;
  final int? selectedChapterId;

  const CourseRecordedLessonsScreenBody({
    super.key,
    required this.course,
    this.selectedChapterId,
  });

  @override
  State<CourseRecordedLessonsScreenBody> createState() =>
      _CourseRecordedLessonsScreenBodyState();
}

class _CourseRecordedLessonsScreenBodyState
    extends State<CourseRecordedLessonsScreenBody>
    with CourseRecordedLessonsMixin {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChapterVideosCubit, ChapterVideosState>(
      builder: (context, state) {
        if (state is AllChapterVideosLoading || state is ChapterVideosInitial) {
          return const CourseRecordedLessonsShimmer();
        }

        // Merge the fetched videos into our course chapters so the UI reflects updates
        final updatedCourse = getUpdatedCourse();

        // Make sure the selected lesson reflects the updated status if it was completed
        syncSelectedLessonWithUpdates();

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
              child: CourseVideoPlayerPlaceholder(
                imageUrl: widget.course.imageUrl ?? '',
                videoUrl: selectedLesson?.videoUrl,
                videoType: selectedLesson?.videoType,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CourseRecordedCurrentLessonInfo(
                      selectedLesson: selectedLesson,
                      course: updatedCourse,
                    ),
                    SizedBox(height: 32.h),
                    CourseRecordedChaptersList(
                      course: updatedCourse,
                      selectedLesson: selectedLesson,
                      onLessonTap: (lesson) =>
                          onLessonTap(lesson, updatedCourse),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

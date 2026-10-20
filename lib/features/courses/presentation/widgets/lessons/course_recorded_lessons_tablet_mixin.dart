import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';
import 'package:pythagoras/features/courses/presentation/cubit/chapter_videos/chapter_videos_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/complete_lesson/complete_lesson_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/complete_video/complete_video_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_recorded_lessons_tablet_landscape.dart';
import 'package:screen_protector/screen_protector.dart';

/// Mixin encapsulating state, lifecycle, security, and video completion
/// for [CourseRecordedLessonsTabletLandscape].
mixin CourseRecordedLessonsTabletMixin
    on State<CourseRecordedLessonsTabletLandscape> {
  CourseLesson? selectedLesson;
  int? selectedChapterId;

  @override
  void initState() {
    super.initState();
    _initSecurity();
    _selectFirstAvailableVideo();

    final cubit = context.read<ChapterVideosCubit>();
    final chapterIds = widget.course.chapters.map((c) => c.id).toList();
    cubit.fetchAllChaptersVideos(chapterIds);
  }

  void _selectFirstAvailableVideo() {
    if (widget.selectedChapterId != null) {
      for (final chapter in widget.course.chapters) {
        if (chapter.id == widget.selectedChapterId &&
            chapter.videos.isNotEmpty) {
          setState(() {
            selectedLesson = chapter.videos.first;
            selectedChapterId = chapter.id;
          });
          _completeSelectedLessonOnLoad(selectedLesson!, chapter.id);
          return;
        }
      }
    }

    for (final chapter in widget.course.chapters) {
      if (chapter.videos.isNotEmpty) {
        setState(() {
          selectedLesson = chapter.videos.first;
          selectedChapterId = chapter.id;
        });
        _completeSelectedLessonOnLoad(selectedLesson!, chapter.id);
        break;
      }
    }
  }

  void _completeSelectedLessonOnLoad(CourseLesson lesson, int chapterId) {
    if (lesson.status != CourseLessonStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleVideoCompletion(lesson.id, chapterId, widget.course);
        }
      });
    }
  }

  CourseDetail getUpdatedCourse() {
    return widget.course.copyWith(
      chapters: widget.course.chapters.map((chapter) {
        final fetchedVideos = context
            .read<ChapterVideosCubit>()
            .getVideosForChapter(chapter.id);
        return chapter.copyWith(videos: fetchedVideos ?? chapter.videos);
      }).toList(),
    );
  }

  void syncSelectedLessonWithUpdates() {
    if (selectedLesson != null && selectedChapterId != null) {
      final fetchedVideos = context
          .read<ChapterVideosCubit>()
          .getVideosForChapter(selectedChapterId!);
      if (fetchedVideos != null) {
        final index = fetchedVideos.indexWhere(
          (v) => v.id == selectedLesson!.id,
        );
        if (index != -1) {
          selectedLesson = fetchedVideos[index];
        }
      }
    }
  }

  void onLessonTap(CourseLesson lesson, CourseDetail updatedCourse) {
    int? chapterId;
    for (final chap in updatedCourse.chapters) {
      if (chap.videos.any((v) => v.id == lesson.id)) {
        chapterId = chap.id;
        break;
      }
    }

    setState(() {
      selectedLesson = lesson;
      if (chapterId != null) {
        selectedChapterId = chapterId;
      }
    });

    if (lesson.status != CourseLessonStatus.completed && chapterId != null) {
      _handleVideoCompletion(lesson.id, chapterId, updatedCourse);
    }
  }

  void _handleVideoCompletion(
    String lessonIdStr,
    int chapterId,
    CourseDetail updatedCourse,
  ) {
    final videoId = int.tryParse(lessonIdStr);
    if (videoId == null) return;

    context.read<ChapterVideosCubit>().markVideoCompleted(chapterId, videoId);

    final completeVideoCubit = context.read<CompleteVideoCubit>();
    final completeLessonCubit = context.read<CompleteLessonCubit>();

    completeVideoCubit.completeVideo(videoId).then((_) {
      if (!mounted) return;

      final chap = updatedCourse.chapters.firstWhere((c) => c.id == chapterId);
      final allVideosCompleted = chap.videos.every(
        (v) => v.status == CourseLessonStatus.completed || v.id == lessonIdStr,
      );

      if (chap.videos.isNotEmpty && allVideosCompleted) {
        completeLessonCubit.completeLesson(chapterId);
      }
    });
  }

  Future<void> _initSecurity() async {
    await ScreenProtector.protectDataLeakageOn();
    await ScreenProtector.preventScreenshotOn();
  }

  Future<void> _disposeSecurity() async {
    await ScreenProtector.protectDataLeakageOff();
    await ScreenProtector.preventScreenshotOff();
  }

  @override
  void dispose() {
    _disposeSecurity();
    super.dispose();
  }
}

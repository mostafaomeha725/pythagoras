import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';
import 'package:pythagoras/features/courses/presentation/cubit/chapter_videos/chapter_videos_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/complete_lesson/complete_lesson_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/complete_video/complete_video_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_recorded_lessons_screen_body.dart';

/// Mixin to handle all UI logic and lifecycle for [CourseRecordedLessonsScreenBody]
/// This follows Clean Code principles by separating UI rendering from state logic.
mixin CourseRecordedLessonsMixin on State<CourseRecordedLessonsScreenBody> {
  CourseLesson? selectedLesson;
  int? selectedChapterId;

  @override
  void initState() {
    super.initState();
    _selectFirstAvailableVideo();
    
    // Fetch videos for all chapters in bulk so the UI can show the Skeleton Shimmer!
    final cubit = context.read<ChapterVideosCubit>();
    final chapterIds = widget.course.chapters.map((c) => c.id).toList();
    cubit.fetchAllChaptersVideos(chapterIds);
  }

  void _selectFirstAvailableVideo() {
    // If a specific chapter was selected, try to find its first video
    if (widget.selectedChapterId != null) {
      for (final chapter in widget.course.chapters) {
        if (chapter.id == widget.selectedChapterId && chapter.videos.isNotEmpty) {
          setState(() {
            selectedLesson = chapter.videos.first;
            selectedChapterId = chapter.id;
          });
          return;
        }
      }
    }
    
    // Fallback: just pick the first available video in the course
    for (final chapter in widget.course.chapters) {
      if (chapter.videos.isNotEmpty) {
        setState(() {
          selectedLesson = chapter.videos.first;
          selectedChapterId = chapter.id;
        });
        break;
      }
    }
  }

  CourseDetail getUpdatedCourse() {
    return widget.course.copyWith(
      chapters: widget.course.chapters.map((chapter) {
        final fetchedVideos = context.read<ChapterVideosCubit>().getVideosForChapter(chapter.id);
        return chapter.copyWith(videos: fetchedVideos ?? chapter.videos);
      }).toList(),
    );
  }

  void syncSelectedLessonWithUpdates() {
    if (selectedLesson != null && selectedChapterId != null) {
      final fetchedVideos = context.read<ChapterVideosCubit>().getVideosForChapter(selectedChapterId!);
      if (fetchedVideos != null) {
        final index = fetchedVideos.indexWhere((v) => v.id == selectedLesson!.id);
        if (index != -1) {
          selectedLesson = fetchedVideos[index];
        }
      }
    }
  }

  void onLessonTap(CourseLesson lesson, CourseDetail updatedCourse) {
    // 1. Find which chapter this lesson belongs to
    int? chapterId;
    for (final chap in updatedCourse.chapters) {
      if (chap.videos.any((v) => v.id == lesson.id)) {
        chapterId = chap.id;
        break;
      }
    }
    
    // 2. Update UI State
    setState(() {
      selectedLesson = lesson;
      if (chapterId != null) {
        selectedChapterId = chapterId;
      }
    });
    
    // 3. Complete video if not already completed
    if (lesson.status != CourseLessonStatus.completed && chapterId != null) {
      _handleVideoCompletion(lesson.id, chapterId, updatedCourse);
    }
  }

  void _handleVideoCompletion(String lessonIdStr, int chapterId, CourseDetail updatedCourse) {
    final videoId = int.tryParse(lessonIdStr);
    if (videoId == null) return;

    // Optimistic UI update
    context.read<ChapterVideosCubit>().markVideoCompleted(chapterId, videoId);
    
    final completeVideoCubit = context.read<CompleteVideoCubit>();
    final completeLessonCubit = context.read<CompleteLessonCubit>();
    
    completeVideoCubit.completeVideo(videoId).then((_) {
      if (!mounted) return;
      
      // Check if this was the last video in the chapter
      final chap = updatedCourse.chapters.firstWhere((c) => c.id == chapterId);
      if (chap.videos.isNotEmpty && chap.videos.last.id == lessonIdStr) {
          // Reached the last video of the chapter/lesson, call completeLesson
          completeLessonCubit.completeLesson(chapterId);
      }
    });
  }
}

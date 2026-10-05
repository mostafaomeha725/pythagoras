import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

abstract class ChapterVideosState {}

class ChapterVideosInitial extends ChapterVideosState {}

class AllChapterVideosLoading extends ChapterVideosState {}

class AllChapterVideosSuccess extends ChapterVideosState {}

class ChapterVideosLoading extends ChapterVideosState {
  final int chapterId;
  ChapterVideosLoading(this.chapterId);
}

class ChapterVideosSuccess extends ChapterVideosState {
  final int chapterId;
  final List<CourseLesson> videos;
  ChapterVideosSuccess({required this.chapterId, required this.videos});
}

class ChapterVideosError extends ChapterVideosState {
  final int chapterId;
  final String message;
  ChapterVideosError({required this.chapterId, required this.message});
}

class ChapterVideosCubit extends Cubit<ChapterVideosState> {
  final CoursesRepository repository;
  
  // Keep track of loaded videos per chapter to avoid refetching unnecessarily
  final Map<int, List<CourseLesson>> _loadedChapters = {};

  ChapterVideosCubit({required this.repository}) : super(ChapterVideosInitial());

  List<CourseLesson>? getVideosForChapter(int chapterId) {
    return _loadedChapters[chapterId];
  }

  void seedChapterVideos(int chapterId, List<CourseLesson> videos) {
    _loadedChapters[chapterId] = videos;
    emit(ChapterVideosSuccess(chapterId: chapterId, videos: videos));
  }

  // Track ongoing fetches to avoid duplicates
  final Set<int> _isFetchingRemote = {};

  Future<void> fetchChapterVideos(int chapterId) async {
    bool hasCache = false;

    // 1. Try memory or local cache
    if (_loadedChapters.containsKey(chapterId)) {
      hasCache = true;
      emit(ChapterVideosSuccess(chapterId: chapterId, videos: _loadedChapters[chapterId]!));
    } else {
      final cacheResult = await repository.getChapterVideos(chapterId, fromCache: true);
      cacheResult.fold(
        (failure) {
          emit(ChapterVideosLoading(chapterId));
        },
        (videos) {
          _loadedChapters[chapterId] = videos;
          hasCache = true;
          emit(ChapterVideosSuccess(chapterId: chapterId, videos: videos));
        },
      );
    }

    if (_isFetchingRemote.contains(chapterId)) return;
    _isFetchingRemote.add(chapterId);

    // 2. Fetch Remote (Background revalidate)
    final result = await repository.getChapterVideos(chapterId, fromCache: false);
    
    _isFetchingRemote.remove(chapterId);

    result.fold(
      (failure) {
        if (!hasCache) {
          if (!isClosed) emit(ChapterVideosError(chapterId: chapterId, message: failure.message));
        }
      },
      (videos) {
        _loadedChapters[chapterId] = videos;
        if (!isClosed) emit(ChapterVideosSuccess(chapterId: chapterId, videos: videos));
      },
    );
  }

  Future<void> fetchAllChaptersVideos(List<int> chapterIds) async {
    final chaptersToFetch = chapterIds.where((id) => !_loadedChapters.containsKey(id)).toList();
    
    if (chaptersToFetch.isEmpty) {
      emit(AllChapterVideosSuccess());
    }

    // 1. Try Cache for missing ones
    if (chaptersToFetch.isNotEmpty) {
      bool hasAnyCache = false;
      await Future.wait(
        chaptersToFetch.map((id) async {
          final result = await repository.getChapterVideos(id, fromCache: true);
          result.fold(
            (failure) => null,
            (videos) {
              _loadedChapters[id] = videos;
              hasAnyCache = true;
            },
          );
        }),
      );

      // Check if we still have completely unloaded chapters
      final stillMissing = chaptersToFetch.where((id) => !_loadedChapters.containsKey(id)).toList();
      if (stillMissing.isEmpty || hasAnyCache) {
        emit(AllChapterVideosSuccess());
      } else {
        emit(AllChapterVideosLoading());
      }
    }

    // 2. Fetch Remote sequentially to avoid spamming the backend
    for (final id in chapterIds) {
      if (_isFetchingRemote.contains(id)) continue;
      _isFetchingRemote.add(id);

      final result = await repository.getChapterVideos(id, fromCache: false);
      
      _isFetchingRemote.remove(id);

      result.fold(
        (failure) => null, // Ignore failures for individual chapters in bulk fetch
        (videos) {
          _loadedChapters[id] = videos;
          if (!isClosed) emit(AllChapterVideosSuccess()); // Update UI smoothly as each chapter finishes
        },
      );
    }
  }
  
  // Update a specific video's status (e.g. after completing it)
  void markVideoCompleted(int chapterId, int videoId) {
    if (_loadedChapters.containsKey(chapterId)) {
      final videos = List<CourseLesson>.from(_loadedChapters[chapterId]!);
      final index = videos.indexWhere((v) => v.id == videoId.toString());
      if (index != -1) {
        videos[index] = videos[index].copyWith(status: CourseLessonStatus.completed);
        _loadedChapters[chapterId] = videos;
        emit(ChapterVideosSuccess(chapterId: chapterId, videos: videos));
      }
    }
  }
}

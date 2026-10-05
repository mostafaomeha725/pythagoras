import 'package:pythagoras/features/courses/domain/entities/course_chapter_statistics.dart';

class CourseChapterStatisticsModel extends CourseChapterStatistics {
  const CourseChapterStatisticsModel({
    required super.videosCount,
    required super.quizzesCount,
    required super.assignmentsCount,
    required super.resourcesCount,
  });

  factory CourseChapterStatisticsModel.fromJson(Map<String, dynamic> json) {
    return CourseChapterStatisticsModel(
      videosCount: json['videos_count'] as int? ?? 0,
      quizzesCount: json['quizzes_count'] as int? ?? 0,
      assignmentsCount: json['assignments_count'] as int? ?? 0,
      resourcesCount: json['resources_count'] as int? ?? 0,
    );
  }
}

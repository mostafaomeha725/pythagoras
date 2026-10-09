import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';

class CourseLessonModel extends CourseLesson {
  const CourseLessonModel({
    required super.id,
    required super.title,
    super.description,
    super.videoUrl,
    super.videoType,
    required super.durationMinutes,
    super.isPreview,
    super.status,
  });

  factory CourseLessonModel.fromJson(Map<String, dynamic> json) {
    // duration might be a string like "11 دقائق" or a number.
    int parsedDuration = 0;
    if (json['duration'] != null) {
      final durStr = json['duration'].toString();
      if (durStr.contains(':')) {
        final parts = durStr.split(':').map((e) => int.tryParse(e) ?? 0).toList();
        if (parts.length == 3) {
          parsedDuration = (parts[0] * 3600) + (parts[1] * 60) + parts[2];
        } else if (parts.length >= 2) {
          parsedDuration = (parts[0] * 60) + parts[1];
        }
      } else {
        final match = RegExp(r'\d+').firstMatch(durStr);
        if (match != null) {
          parsedDuration = (int.tryParse(match.group(0) ?? '0') ?? 0) * 60; // Assume flat numbers are minutes
        }
      }
    }
    bool isCompleted = false;
    if (json['is_completed'] != null) {
      final val = json['is_completed'];
      if (val is bool) {
        isCompleted = val;
      } else if (val is int) {
        isCompleted = val == 1;
      } else if (val is String) {
        isCompleted = val == '1' || val.toLowerCase() == 'true';
      }
    }

    return CourseLessonModel(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      videoUrl: json['video_url'] as String?,
      videoType: json['video_type'] as String?,
      durationMinutes: parsedDuration,
      isPreview: false,
      status: isCompleted 
          ? CourseLessonStatus.completed 
          : CourseLessonStatus.unplayed,
    );
  }
}

import 'package:pythagoras/features/courses/domain/entities/live_session.dart';

class LiveSessionModel extends LiveSession {
  const LiveSessionModel({
    required super.id,
    required super.name,
    required super.link,
    required super.scheduledAt,
    required super.scheduledAtStr,
    required super.courseId,
    required super.courseTitle,
    required super.createdAt,
  });

  factory LiveSessionModel.fromJson(Map<String, dynamic> json) {
    return LiveSessionModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      link: json['link'] as String? ?? '',
      scheduledAt: DateTime.tryParse(json['scheduled_at']?.toString() ?? '') ?? DateTime.now(),
      scheduledAtStr: json['scheduled_at']?.toString() ?? '',
      courseId: json['course_id'] as int? ?? 0,
      courseTitle: json['course_title'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

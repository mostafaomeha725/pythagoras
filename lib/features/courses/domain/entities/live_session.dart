import 'package:equatable/equatable.dart';

class LiveSession extends Equatable {
  final int id;
  final String name;
  final String link;
  final DateTime scheduledAt;
  final String scheduledAtStr;
  final int courseId;
  final String courseTitle;
  final DateTime createdAt;

  const LiveSession({
    required this.id,
    required this.name,
    required this.link,
    required this.scheduledAt,
    required this.scheduledAtStr,
    required this.courseId,
    required this.courseTitle,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        link,
        scheduledAt,
        scheduledAtStr,
        courseId,
        courseTitle,
        createdAt,
      ];
}

enum CourseLessonStatus {
  locked,
  unplayed,
  playing,
  completed,
}

class CourseLesson {
  final String id;
  final String title;
  final String? description;
  final String? videoUrl;
  final String? videoType;
  final int durationMinutes;
  final bool isPreview;
  final CourseLessonStatus status;

  const CourseLesson({
    required this.id,
    required this.title,
    this.description,
    this.videoUrl,
    this.videoType,
    required this.durationMinutes,
    this.isPreview = false,
    this.status = CourseLessonStatus.unplayed,
  });

  CourseLesson copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? videoType,
    int? durationMinutes,
    bool? isPreview,
    CourseLessonStatus? status,
  }) {
    return CourseLesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      videoType: videoType ?? this.videoType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isPreview: isPreview ?? this.isPreview,
      status: status ?? this.status,
    );
  }
}

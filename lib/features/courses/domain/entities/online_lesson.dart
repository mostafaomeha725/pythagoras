enum OnlineLessonStatus { live, upcoming }

class OnlineLesson {
  final String title;
  final String subject;
  final String teacherName;
  final String dateString;
  final String timeString;
  final int durationMinutes;
  final String platform;
  final String joinUrl;
  final OnlineLessonStatus status;

  const OnlineLesson({
    required this.title,
    required this.subject,
    required this.teacherName,
    required this.dateString,
    required this.timeString,
    required this.durationMinutes,
    required this.platform,
    required this.joinUrl,
    required this.status,
  });
}

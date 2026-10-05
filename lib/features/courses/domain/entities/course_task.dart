enum CourseTaskStatus { upcoming, completed }
enum CourseTaskType { exam, assignment }

class CourseTask {
  final String title;
  final String subject;
  final String subSubject;
  final String deadlineDateString;
  final String deadlineTimeString;
  final String score;
  final String completedDateString;
  final CourseTaskStatus status;
  final CourseTaskType type;
  final String actionLabel;

  const CourseTask({
    required this.title,
    required this.subject,
    required this.subSubject,
    this.deadlineDateString = '',
    this.deadlineTimeString = '',
    this.score = '',
    this.completedDateString = '',
    required this.status,
    required this.type,
    required this.actionLabel,
  });
}

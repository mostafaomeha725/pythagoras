/// Represents the enrollment / request status badge displayed on a course card.
enum CourseBadgeType {
  /// No badge should be shown on the course image/card.
  none,

  /// Full course is enrolled/accepted ('مسجل').
  courseEnrolled,

  /// Full course request is pending approval ('قيد الانتظار').
  coursePending,

  /// Single chapter is enrolled/accepted ('حصة مسجلة').
  chapterEnrolled,

  /// Single chapter request is pending approval ('حصة قيد الانتظار').
  chapterPending,
}

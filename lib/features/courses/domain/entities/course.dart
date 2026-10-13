import 'package:pythagoras/features/courses/domain/entities/course_badge_type.dart';

class Course {
  final String id;
  final String title;
  final String? imageUrl;
  final double price;
  final bool isEnrolled;
  final String? level;
  final String? className;
  final int? semester;
  final String? requestStatus;
  final String? chapterRequest;
  final double? finalPrice;
  final String? currencyLabel;
  final int? studentsCount;
  final bool? isSaved;

  Course({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.price,
    this.isEnrolled = false,
    this.level,
    this.className,
    this.semester,
    this.requestStatus,
    this.chapterRequest,
    this.finalPrice,
    this.currencyLabel,
    this.studentsCount,
    this.isSaved,
  });

  /// Evaluates request status for course and chapter according to business rules:
  /// - Course accepted / enrolled -> [CourseBadgeType.courseEnrolled] ('مسجل')
  /// - Course pending -> [CourseBadgeType.coursePending] ('قيد الانتظار')
  /// - Course not_requested -> looks at chapter_request:
  ///     - Chapter accepted -> [CourseBadgeType.chapterEnrolled] ('حصة مسجلة')
  ///     - Chapter pending -> [CourseBadgeType.chapterPending] ('حصة قيد الانتظار', yellow)
  ///     - Chapter not_requested -> [CourseBadgeType.none] (no badge shown)
  CourseBadgeType get badgeType {
    final req = requestStatus?.trim().toLowerCase();
    final chap = chapterRequest?.trim().toLowerCase();

    // 1. Full course accepted or already enrolled
    if (isEnrolled || req == 'accepted') {
      return CourseBadgeType.courseEnrolled;
    }

    // 2. Full course pending
    if (req == 'pending') {
      return CourseBadgeType.coursePending;
    }

    // 3. Fallback to chapter request when course is not requested
    if (chap == 'accepted') {
      return CourseBadgeType.chapterEnrolled;
    }
    if (chap == 'pending') {
      return CourseBadgeType.chapterPending;
    }

    return CourseBadgeType.none;
  }
}

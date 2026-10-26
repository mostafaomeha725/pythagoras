import 'package:pythagoras/features/courses/domain/entities/course_badge_type.dart';
import 'package:pythagoras/features/courses/domain/entities/course_chapter.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail_instructor.dart';

class CourseDetail {
  final int id;
  final String title;
  final String? description;
  final String level;
  final String className;
  final String? imageUrl;
  final String? introVideoUrl;
  final String? introVideoType;
  final bool isEnrolled;
  final String price;
  final String? discountPrice;
  final num finalPrice;
  final String currencyLabel;
  final int studentsCount;
  final bool isSaved;
  final String? requestStatus;
  final String? chapterRequest;
  final String? appleProductId;

  final num rating;
  final String category;

  final CourseDetailInstructor? instructor;
  final List<CourseChapter> chapters;

  const CourseDetail({
    required this.id,
    required this.title,
    this.description,
    required this.level,
    required this.className,
    this.imageUrl,
    this.introVideoUrl,
    this.introVideoType,
    required this.isEnrolled,
    required this.price,
    this.discountPrice,
    required this.finalPrice,
    required this.currencyLabel,
    required this.studentsCount,
    required this.isSaved,
    this.requestStatus,
    this.chapterRequest,
    this.appleProductId,
    required this.rating,
    required this.category,
    this.instructor,
    required this.chapters,
  });

  CourseDetail copyWith({
    int? id,
    String? title,
    String? description,
    String? level,
    String? className,
    String? imageUrl,
    String? introVideoUrl,
    String? introVideoType,
    bool? isEnrolled,
    String? price,
    String? discountPrice,
    num? finalPrice,
    String? currencyLabel,
    int? studentsCount,
    bool? isSaved,
    String? requestStatus,
    String? chapterRequest,
    String? appleProductId,
    num? rating,
    String? category,
    CourseDetailInstructor? instructor,
    List<CourseChapter>? chapters,
  }) {
    return CourseDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      className: className ?? this.className,
      imageUrl: imageUrl ?? this.imageUrl,
      introVideoUrl: introVideoUrl ?? this.introVideoUrl,
      introVideoType: introVideoType ?? this.introVideoType,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      currencyLabel: currencyLabel ?? this.currencyLabel,
      studentsCount: studentsCount ?? this.studentsCount,
      isSaved: isSaved ?? this.isSaved,
      requestStatus: requestStatus ?? this.requestStatus,
      chapterRequest: chapterRequest ?? this.chapterRequest,
      appleProductId: appleProductId ?? this.appleProductId,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      instructor: instructor ?? this.instructor,
      chapters: chapters ?? this.chapters,
    );
  }

  /// Evaluates request status for course and chapter according to business rules:
  /// - Course accepted / enrolled -> [CourseBadgeType.courseEnrolled] ('مسجل')
  /// - Course pending -> [CourseBadgeType.coursePending] ('قيد الانتظار')
  /// - Course not_requested -> looks at chapter_request:
  ///     - Chapter accepted -> [CourseBadgeType.chapterEnrolled] ('حصة مسجلة')
  ///     - Chapter pending -> [CourseBadgeType.chapterPending] ('حصة قيد الانتظار', yellow)
  ///     - Chapter not_requested -> [CourseBadgeType.none] (no badge shown)
  CourseBadgeType get badgeType {
    final req = requestStatus?.trim().toLowerCase();
    final chap = (chapterRequest ?? _derivedChapterRequest)
        ?.trim()
        .toLowerCase();

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

  String? get _derivedChapterRequest {
    for (final chapter in chapters) {
      final s = chapter.requestStatus.trim().toLowerCase();
      if (s == 'accepted') return 'accepted';
    }
    for (final chapter in chapters) {
      final s = chapter.requestStatus.trim().toLowerCase();
      if (s == 'pending') return 'pending';
    }
    return null;
  }
}

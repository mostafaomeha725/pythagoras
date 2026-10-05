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
  final bool isEnrolled;
  final String price;
  final String? discountPrice;
  final num finalPrice;
  final String currencyLabel;
  final int studentsCount;
  final bool isSaved;
  final String? requestStatus;

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
    required this.isEnrolled,
    required this.price,
    this.discountPrice,
    required this.finalPrice,
    required this.currencyLabel,
    required this.studentsCount,
    required this.isSaved,
    this.requestStatus,
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
    bool? isEnrolled,
    String? price,
    String? discountPrice,
    num? finalPrice,
    String? currencyLabel,
    int? studentsCount,
    bool? isSaved,
    String? requestStatus,
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
      isEnrolled: isEnrolled ?? this.isEnrolled,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      currencyLabel: currencyLabel ?? this.currencyLabel,
      studentsCount: studentsCount ?? this.studentsCount,
      isSaved: isSaved ?? this.isSaved,
      requestStatus: requestStatus ?? this.requestStatus,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      instructor: instructor ?? this.instructor,
      chapters: chapters ?? this.chapters,
    );
  }
}


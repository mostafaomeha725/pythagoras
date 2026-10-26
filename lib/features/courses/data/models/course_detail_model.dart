import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/data/models/course_chapter_model.dart';
import 'package:pythagoras/features/courses/data/models/course_detail_instructor_model.dart';

class CourseDetailModel extends CourseDetail {
  const CourseDetailModel({
    required super.id,
    required super.title,
    super.description,
    required super.level,
    required super.className,
    super.imageUrl,
    super.introVideoUrl,
    super.introVideoType,
    required super.isEnrolled,
    required super.price,
    super.discountPrice,
    required super.finalPrice,
    required super.currencyLabel,
    required super.studentsCount,
    required super.isSaved,
    super.requestStatus,
    super.chapterRequest,
    super.appleProductId,
    required super.rating,
    required super.category,
    super.instructor,
    required super.chapters,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    final general = json['general'] as Map<String, dynamic>? ?? {};
    final chaptersData = json['chapters'] as List<dynamic>? ?? [];
    final appleProductId = (json['apple_product_id'] ?? json['appleProductId'])
        ?.toString();
    final requestStatus = (json['request_status'] as String?)
        ?.trim()
        .toLowerCase();
    final isEnrolled = json['is_enrolled'] as bool? ?? false;

    final chapters = chaptersData
        .map((e) => CourseChapterModel.fromJson(e))
        .toList();

    return CourseDetailModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      level: json['level'] as String? ?? '',
      className: json['class_name'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      introVideoUrl: json['intro_video_url'] as String?,
      introVideoType: json['intro_video_type'] as String?,
      isEnrolled: isEnrolled || requestStatus == 'accepted',
      price: json['price'] as String? ?? '0',
      discountPrice: json['discount_price'] as String?,
      finalPrice: json['final_price'] as num? ?? 0,
      currencyLabel: json['currency_label'] as String? ?? '',
      studentsCount: json['students_count'] as int? ?? 0,
      isSaved: json['is_saved'] as bool? ?? false,
      requestStatus: requestStatus,
      chapterRequest: json['chapter_request'] as String?,
      appleProductId: appleProductId,
      rating: general['rating'] as num? ?? 0,
      category: general['category'] as String? ?? '',
      instructor: json['instructor'] != null
          ? CourseDetailInstructorModel.fromJson(json['instructor'])
          : null,
      chapters: chapters,
    );
  }
}

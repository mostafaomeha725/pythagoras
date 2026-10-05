import 'package:pythagoras/features/courses/domain/entities/course.dart';

class CourseModel extends Course {
  CourseModel({
    required super.id,
    required super.title,
    super.imageUrl,
    required super.price,
    super.isEnrolled,
    super.level,
    super.className,
    super.semester,
    super.requestStatus,
    super.finalPrice,
    super.currencyLabel,
    super.studentsCount,
    super.isSaved,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      imageUrl: json['image_url'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      isEnrolled: json['is_enrolled'] ?? false,
      level: json['level'],
      className: json['class_name'],
      semester: json['semester'],
      requestStatus: json['request_status'],
      finalPrice: double.tryParse(json['final_price']?.toString() ?? '0') ?? 0.0,
      currencyLabel: json['currency_label'] ?? '',
      studentsCount: json['students_count'] ?? 0,
      isSaved: json['is_saved'] ?? false,
    );
  }
}

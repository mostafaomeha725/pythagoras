import 'package:pythagoras/features/courses/domain/entities/course_review.dart';

class CourseReviewModel extends CourseReview {
  const CourseReviewModel({
    required super.id,
    required super.userName,
    super.userAvatarUrl,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  factory CourseReviewModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>?;
    return CourseReviewModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userName: userMap?['name']?.toString() ?? 'مستخدم',
      userAvatarUrl: userMap?['avatar_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}

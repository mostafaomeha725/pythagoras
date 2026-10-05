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
    return CourseReviewModel(
      id: json['id'] as int,
      userName: json['user']['name'] as String,
      userAvatarUrl: json['user']['avatar_url'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

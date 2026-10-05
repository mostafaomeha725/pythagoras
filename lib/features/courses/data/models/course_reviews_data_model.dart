import 'package:pythagoras/features/courses/domain/entities/course_reviews_data.dart';
import 'package:pythagoras/features/courses/data/models/course_review_model.dart';

class CourseReviewsDataModel extends CourseReviewsData {
  const CourseReviewsDataModel({
    required super.ratingsDistribution,
    required super.averageRating,
    required super.maxRating,
    required super.averageDisplay,
    required super.totalReviews,
    required super.reviews,
  });

  factory CourseReviewsDataModel.fromJson(Map<String, dynamic> json) {
    Map<int, double> distribution = {};
    if (json['ratings_distribution'] != null) {
      final map = json['ratings_distribution'] as Map<String, dynamic>;
      map.forEach((key, value) {
        distribution[int.parse(key)] = (value as num).toDouble();
      });
    }

    return CourseReviewsDataModel(
      ratingsDistribution: distribution,
      averageRating: (json['average_rating'] as num).toDouble(),
      maxRating: json['max_rating'] as int,
      averageDisplay: json['average_display'] as String,
      totalReviews: json['total_reviews'] as int,
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => CourseReviewModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

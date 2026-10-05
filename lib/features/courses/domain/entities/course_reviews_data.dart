import 'package:pythagoras/features/courses/domain/entities/course_review.dart';

class CourseReviewsData {
  final Map<int, double> ratingsDistribution;
  final double averageRating;
  final int maxRating;
  final String averageDisplay;
  final int totalReviews;
  final List<CourseReview> reviews;

  const CourseReviewsData({
    required this.ratingsDistribution,
    required this.averageRating,
    required this.maxRating,
    required this.averageDisplay,
    required this.totalReviews,
    required this.reviews,
  });
}

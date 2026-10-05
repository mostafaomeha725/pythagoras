class CourseReview {
  final int id;
  final String userName;
  final String? userAvatarUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const CourseReview({
    required this.id,
    required this.userName,
    this.userAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

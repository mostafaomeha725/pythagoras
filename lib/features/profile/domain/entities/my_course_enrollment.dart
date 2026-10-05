class MyCourseEnrollment {
  final int enrollmentId;
  final String status;
  final int progress;
  final String? startedAt;
  final EnrolledCourse course;

  MyCourseEnrollment({
    required this.enrollmentId,
    required this.status,
    required this.progress,
    this.startedAt,
    required this.course,
  });
}

class EnrolledCourse {
  final int id;
  final String title;
  final String? coverUrl;
  final String price;
  final num? finalPrice;
  final String currencyLabel;
  final EnrolledInstructor? instructor;

  EnrolledCourse({
    required this.id,
    required this.title,
    this.coverUrl,
    required this.price,
    this.finalPrice,
    required this.currencyLabel,
    this.instructor,
  });
}

class EnrolledInstructor {
  final int id;
  final String name;
  final String? image;

  EnrolledInstructor({
    required this.id,
    required this.name,
    this.image,
  });
}

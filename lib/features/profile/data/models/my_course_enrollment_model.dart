import 'package:pythagoras/features/profile/domain/entities/my_course_enrollment.dart';

class MyCourseEnrollmentModel extends MyCourseEnrollment {
  MyCourseEnrollmentModel({
    required super.enrollmentId,
    required super.status,
    required super.progress,
    super.startedAt,
    required super.course,
  });

  factory MyCourseEnrollmentModel.fromJson(Map<String, dynamic> json) {
    return MyCourseEnrollmentModel(
      enrollmentId: json['enrollment_id'] is int 
          ? json['enrollment_id'] 
          : int.tryParse(json['enrollment_id']?.toString() ?? '') ?? 0,
      status: json['status'] ?? '',
      progress: json['progress'] is int 
          ? json['progress'] 
          : (double.tryParse(json['progress']?.toString() ?? '')?.toInt() ?? 0),
      startedAt: json['started_at'],
      course: EnrolledCourseModel.fromJson(json['course'] ?? {}),
    );
  }
}

class EnrolledCourseModel extends EnrolledCourse {
  EnrolledCourseModel({
    required super.id,
    required super.title,
    super.coverUrl,
    required super.price,
    super.finalPrice,
    required super.currencyLabel,
    super.instructor,
  });

  factory EnrolledCourseModel.fromJson(Map<String, dynamic> json) {
    return EnrolledCourseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      coverUrl: json['cover_url'],
      price: json['price']?.toString() ?? '0',
      finalPrice: json['final_price'],
      currencyLabel: json['currency_label'] ?? '',
      instructor: json['instructor'] != null
          ? EnrolledInstructorModel.fromJson(json['instructor'])
          : null,
    );
  }
}

class EnrolledInstructorModel extends EnrolledInstructor {
  EnrolledInstructorModel({
    required super.id,
    required super.name,
    super.image,
  });

  factory EnrolledInstructorModel.fromJson(Map<String, dynamic> json) {
    return EnrolledInstructorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
    );
  }
}

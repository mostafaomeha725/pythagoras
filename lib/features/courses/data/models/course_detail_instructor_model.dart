import 'package:pythagoras/features/courses/domain/entities/course_detail_instructor.dart';

class CourseDetailInstructorModel extends CourseDetailInstructor {
  const CourseDetailInstructorModel({
    required super.id,
    required super.name,
    required super.title,
    required super.major,
    required super.bio,
    super.image,
  });

  factory CourseDetailInstructorModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailInstructorModel(
      id: json['id'] as int,
      name: json['name'] as String,
      title: json['title'] as String? ?? '',
      major: json['major'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      image: json['image'] as String?,
    );
  }
}

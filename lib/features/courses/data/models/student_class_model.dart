import 'package:pythagoras/features/courses/domain/entities/student_class.dart';

class StudentClassModel extends StudentClass {
  const StudentClassModel({
    required super.id,
    required super.name,
  });

  factory StudentClassModel.fromJson(Map<String, dynamic> json) {
    return StudentClassModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}

import 'package:pythagoras/features/courses/domain/entities/course_attachment.dart';

class CourseAssignment {
  final int id;
  final String title;
  final String? description;
  final String? dueDate;
  final int maxPoints;
  final CourseAttachment? assignmentFile;

  const CourseAssignment({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.maxPoints,
    this.assignmentFile,
  });
}

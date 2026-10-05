import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:pythagoras/features/courses/data/models/course_attachment_model.dart';

class CourseAssignmentModel extends CourseAssignment {
  const CourseAssignmentModel({
    required super.id,
    required super.title,
    super.description,
    super.dueDate,
    required super.maxPoints,
    super.assignmentFile,
  });

  factory CourseAssignmentModel.fromJson(Map<String, dynamic> json) {
    return CourseAssignmentModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      dueDate: json['due_date'] as String?,
      maxPoints: json['max_points'] as int? ?? 0,
      assignmentFile: json['assignment_file'] != null
          ? CourseAttachmentModel.fromJson(json['assignment_file'])
          : null,
    );
  }
}

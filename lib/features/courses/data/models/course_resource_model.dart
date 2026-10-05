import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';
import 'package:pythagoras/features/courses/data/models/course_attachment_model.dart';

class CourseResourceModel extends CourseResource {
  const CourseResourceModel({
    required super.id,
    required super.title,
    required super.description,
    super.type,
    required super.fileUrl,
    super.file,
  });

  factory CourseResourceModel.fromJson(Map<String, dynamic> json) {
    return CourseResourceModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String?,
      fileUrl: json['file_url'] as String? ?? '',
      file: json['file'] != null ? CourseAttachmentModel.fromJson(json['file'] as Map<String, dynamic>) : null,
    );
  }
}

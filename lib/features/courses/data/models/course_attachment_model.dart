import 'package:pythagoras/features/courses/domain/entities/course_attachment.dart';

class CourseAttachmentModel extends CourseAttachment {
  const CourseAttachmentModel({
    required super.name,
    required super.url,
    required super.mimeType,
    required super.size,
    super.extension,
  });

  factory CourseAttachmentModel.fromJson(Map<String, dynamic> json) {
    return CourseAttachmentModel(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      mimeType: json['mime_type'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      extension: json['extension'] as String?,
    );
  }
}

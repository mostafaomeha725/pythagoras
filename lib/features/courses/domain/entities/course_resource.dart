import 'package:equatable/equatable.dart';
import 'package:pythagoras/features/courses/domain/entities/course_attachment.dart';

class CourseResource extends Equatable {
  final int id;
  final String title;
  final String description;
  final String? type;
  final String fileUrl;
  final CourseAttachment? file;

  const CourseResource({
    required this.id,
    required this.title,
    required this.description,
    this.type,
    required this.fileUrl,
    this.file,
  });

  @override
  List<Object?> get props => [id, title, description, type, fileUrl, file];
}

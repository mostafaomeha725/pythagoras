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

  /// Returns the normalized uppercase file extension (e.g. 'PDF', 'DOCX', 'PPTX', etc.)
  String get fileExtension {
    final ext = file?.extension?.trim();
    if (ext != null && ext.isNotEmpty) {
      final clean = ext.replaceAll('.', '').toUpperCase();
      if (clean.isNotEmpty) {
        if (clean == 'WORD') return 'DOCX';
        return clean.length > 5 ? clean.substring(0, 5) : clean;
      }
    }

    final name = file?.name.trim();
    if (name != null && name.contains('.')) {
      final extFromName = name
          .split('?')
          .first
          .split('.')
          .last
          .trim()
          .toUpperCase();
      if (extFromName.isNotEmpty && extFromName.length <= 5) {
        return extFromName;
      }
    }

    if (fileUrl.isNotEmpty && fileUrl.contains('.')) {
      final cleanUrl = fileUrl.split('?').first.split('#').first;
      final extFromUrl = cleanUrl.split('.').last.trim().toUpperCase();
      if (extFromUrl.isNotEmpty &&
          extFromUrl.length <= 5 &&
          !extFromUrl.contains('/')) {
        return extFromUrl;
      }
    }

    if (type != null && type!.trim().isNotEmpty) {
      final t = type!.trim().toUpperCase();
      if (t == 'WORD') return 'DOCX';
      if (t.length <= 5) return t;
    }

    final mime = file?.mimeType.toLowerCase();
    if (mime != null && mime.isNotEmpty) {
      if (mime.contains('pdf')) return 'PDF';
      if (mime.contains('word') ||
          mime.contains('officedocument.wordprocessingml'))
        return 'DOCX';
      if (mime.contains('presentation') || mime.contains('powerpoint'))
        return 'PPTX';
      if (mime.contains('sheet') || mime.contains('excel')) return 'XLSX';
      if (mime.contains('png')) return 'PNG';
      if (mime.contains('jpeg') || mime.contains('jpg')) return 'JPG';
    }

    return 'PDF';
  }

  /// Whether this resource is a PDF file
  bool get isPdf {
    final ext = fileExtension.toUpperCase();
    if (ext == 'PDF') return true;
    final cleanUrl = fileUrl.split('?').first.toLowerCase();
    return cleanUrl.endsWith('.pdf');
  }

  /// Whether this resource is an Office document (Word, Excel, PowerPoint)
  bool get isDoc {
    final ext = fileExtension.toUpperCase();
    const docExtensions = ['DOC', 'DOCX', 'WORD', 'PPT', 'PPTX', 'XLS', 'XLSX'];
    if (docExtensions.contains(ext)) return true;
    final cleanUrl = fileUrl.split('?').first.toLowerCase();
    return docExtensions.any((e) => cleanUrl.endsWith('.${e.toLowerCase()}'));
  }
}

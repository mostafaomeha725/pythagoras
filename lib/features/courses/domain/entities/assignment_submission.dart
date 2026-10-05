import 'package:pythagoras/features/courses/domain/entities/course_attachment.dart';

class AssignmentSubmission {
  final int id;
  final int assignmentId;
  final int userId;
  final String? notes;
  final int? pointsAwarded;
  final String? feedback;
  final String submittedAt;
  final List<CourseAttachment> submittedFiles;

  const AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.userId,
    this.notes,
    this.pointsAwarded,
    this.feedback,
    required this.submittedAt,
    required this.submittedFiles,
  });
}

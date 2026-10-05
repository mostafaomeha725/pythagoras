import 'package:pythagoras/features/courses/data/models/course_attachment_model.dart';
import 'package:pythagoras/features/courses/domain/entities/assignment_submission.dart';

class AssignmentSubmissionModel extends AssignmentSubmission {
  const AssignmentSubmissionModel({
    required super.id,
    required super.assignmentId,
    required super.userId,
    super.notes,
    super.pointsAwarded,
    super.feedback,
    required super.submittedAt,
    required super.submittedFiles,
  });

  factory AssignmentSubmissionModel.fromJson(Map<String, dynamic> json) {
    final filesData = json['submitted_files'] as List<dynamic>? ?? [];
    return AssignmentSubmissionModel(
      id: json['id'] as int,
      assignmentId: int.tryParse(json['assignment_id'].toString()) ?? 0,
      userId: json['user_id'] as int,
      notes: json['notes'] as String?,
      pointsAwarded: json['points_awarded'] as int?,
      feedback: json['feedback'] as String?,
      submittedAt: json['submitted_at'] as String? ?? '',
      submittedFiles: filesData
          .map((f) => CourseAttachmentModel.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}

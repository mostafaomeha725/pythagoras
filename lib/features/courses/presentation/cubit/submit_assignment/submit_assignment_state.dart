import 'package:pythagoras/features/courses/domain/entities/assignment_submission.dart';

abstract class SubmitAssignmentState {}

class SubmitAssignmentInitial extends SubmitAssignmentState {}

class SubmitAssignmentLoading extends SubmitAssignmentState {}

class SubmitAssignmentSuccess extends SubmitAssignmentState {
  final AssignmentSubmission submission;
  SubmitAssignmentSuccess(this.submission);
}

class SubmitAssignmentError extends SubmitAssignmentState {
  final String message;
  SubmitAssignmentError(this.message);
}

// Submissions list states
class SubmissionsLoading extends SubmitAssignmentState {}

class SubmissionsLoaded extends SubmitAssignmentState {
  final List<AssignmentSubmission> submissions;
  SubmissionsLoaded(this.submissions);
}

class SubmissionsError extends SubmitAssignmentState {
  final String message;
  SubmissionsError(this.message);
}

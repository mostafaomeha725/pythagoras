import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/use_cases/submit_assignment_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_assignment_submissions_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/submit_assignment/submit_assignment_state.dart';

class SubmitAssignmentCubit extends Cubit<SubmitAssignmentState> {
  final SubmitAssignmentUseCase submitAssignmentUseCase;
  final GetAssignmentSubmissionsUseCase getAssignmentSubmissionsUseCase;

  SubmitAssignmentCubit(
    this.submitAssignmentUseCase,
    this.getAssignmentSubmissionsUseCase,
  ) : super(SubmitAssignmentInitial());

  Future<void> submit({
    required int assignmentId,
    String? notes,
    String? filePath,
    String? fileName,
  }) async {
    emit(SubmitAssignmentLoading());
    final result = await submitAssignmentUseCase(
      assignmentId: assignmentId,
      notes: notes,
      filePath: filePath,
      fileName: fileName,
    );
    result.fold(
      (failure) => emit(SubmitAssignmentError(failure.message)),
      (submission) => emit(SubmitAssignmentSuccess(submission)),
    );
  }

  Future<void> fetchSubmissions(int assignmentId) async {
    emit(SubmissionsLoading());
    final result = await getAssignmentSubmissionsUseCase(assignmentId);
    result.fold(
      (failure) => emit(SubmissionsError(failure.message)),
      (submissions) => emit(SubmissionsLoaded(submissions)),
    );
  }
}

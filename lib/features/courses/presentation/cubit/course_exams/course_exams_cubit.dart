import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_course_assignments_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_assignment_submissions_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_course_quizzes_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_exams/course_exams_state.dart';
import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';

class CourseExamsCubit extends Cubit<CourseExamsState> {
  final GetCourseAssignmentsUseCase getCourseAssignmentsUseCase;
  final GetAssignmentSubmissionsUseCase getAssignmentSubmissionsUseCase;
  final GetCourseQuizzesUseCase getCourseQuizzesUseCase;

  CourseExamsCubit({
    required this.getCourseAssignmentsUseCase,
    required this.getAssignmentSubmissionsUseCase,
    required this.getCourseQuizzesUseCase,
  }) : super(CourseExamsInitial());

  bool _isFetchingRemote = false;

  Future<void> fetchExamsAndAssignments(int courseId, {bool showLoading = false}) async {
    if (showLoading) {
      emit(CourseExamsLoading());
      _isFetchingRemote = true;
      await _loadExamsData(courseId, fromCache: false);
      if (isClosed) return;
      _isFetchingRemote = false;
      return;
    }

    // 1. Try to load from Cache first
    final hasCache = await _loadExamsData(courseId, fromCache: true);
    
    if (isClosed) return;

    if (!hasCache) {
      emit(CourseExamsLoading());
    }

    if (_isFetchingRemote) return;
    _isFetchingRemote = true;

    // 2. Load from Remote (Background refresh)
    await _loadExamsData(courseId, fromCache: false);
    
    if (isClosed) return;
    _isFetchingRemote = false;
  }

  Future<bool> _loadExamsData(int courseId, {required bool fromCache}) async {
    final results = await Future.wait([
      getCourseAssignmentsUseCase(courseId, fromCache: fromCache),
      getCourseQuizzesUseCase(courseId, fromCache: fromCache),
    ]);

    if (isClosed) return false;

    final assignmentsResult = results[0] as dynamic;
    final quizzesResult = results[1] as dynamic;

    final upcoming = <CourseTaskItem>[];
    final completed = <CourseTaskItem>[];

    String? errorMessage;
    bool dataFound = false;

    // Process Assignments
    await assignmentsResult.fold(
      (failure) async => errorMessage = failure.message,
      (assignments) async {
        final List<CourseAssignment> assignmentList = assignments;
        if (assignmentList.isNotEmpty) dataFound = true;

        final submissionFutures = assignmentList
            .map((a) => getAssignmentSubmissionsUseCase(a.id, fromCache: fromCache))
            .toList();
        final submissionResults = await Future.wait(submissionFutures);

        if (isClosed) return;

        for (var i = 0; i < assignmentList.length; i++) {
          final assignment = assignmentList[i];
          final subResult = submissionResults[i];

          subResult.fold(
            (l) =>
                upcoming.add(CourseTaskItem.assignment(assignment: assignment)),
            (submissions) {
              if (submissions.isNotEmpty) {
                completed.add(
                  CourseTaskItem.assignment(
                    assignment: assignment,
                    submission: submissions.first,
                  ),
                );
              } else {
                upcoming.add(CourseTaskItem.assignment(assignment: assignment));
              }
            },
          );
        }
      },
    );

    if (isClosed) return false;

    // Process Quizzes
    await quizzesResult.fold(
      (failure) async {
        errorMessage ??= failure.message;
      },
      (quizzes) async {
        final List<CourseQuiz> quizList = quizzes;
        if (quizList.isNotEmpty) dataFound = true;

        for (final quiz in quizList) {
          // If the student still has remaining attempts, show in upcoming tasks
          if (quiz.canAttempt) {
            upcoming.add(CourseTaskItem.quiz(quiz: quiz));
          }

          // If the student already completed an attempt (has an inline result or currentAttempts > 0),
          // OR if the quiz can no longer be attempted (!canAttempt), show in completed tasks
          final hasAttempted =
              quiz.inlineResult != null || quiz.currentAttempts > 0;
          if (hasAttempted || !quiz.canAttempt) {
            completed.add(
              CourseTaskItem.quiz(quiz: quiz, quizResult: quiz.inlineResult),
            );
          }
        }
      },
    );

    if (isClosed) return false;

    if (fromCache) {
      if (dataFound) {
        emit(CourseExamsLoaded(upcomingTasks: upcoming, completedTasks: completed));
        return true;
      }
      return false;
    } else {
      if (errorMessage != null && upcoming.isEmpty && completed.isEmpty) {
        if (state is! CourseExamsLoaded) {
          emit(CourseExamsError(errorMessage!));
        }
      } else {
        emit(
          CourseExamsLoaded(upcomingTasks: upcoming, completedTasks: completed),
        );
      }
      return true;
    }
  }
}

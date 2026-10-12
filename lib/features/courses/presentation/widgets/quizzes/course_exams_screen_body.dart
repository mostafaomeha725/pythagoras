import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_exams/course_exams_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_exams/course_exams_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/course_assignment_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/course_quiz_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/course_exams_stats_row.dart';
import 'package:pythagoras/features/courses/presentation/widgets/completed_cards/course_task_completed_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/course_quiz_completed_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/exams_screen_widgets.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/course_exams_shimmer.dart';


class CourseExamsScreenBody extends StatelessWidget {
  final CourseDetail course;

  const CourseExamsScreenBody({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseExamsCubit, CourseExamsState>(
      builder: (context, state) {
        if (state is CourseExamsLoading) {
          return const CourseExamsShimmer();
        }

        if (state is CourseExamsError) {
          return NoInternetWidget(
            message: state.message,
            onRetry: () => context
                .read<CourseExamsCubit>()
                .fetchExamsAndAssignments(course.id, showLoading: true),
          );
        }

        final upcoming = state is CourseExamsLoaded
            ? state.upcomingTasks
            : <CourseTaskItem>[];
        final completed = state is CourseExamsLoaded
            ? state.completedTasks
            : <CourseTaskItem>[];

        num totalScore = 0;
        num maxPossible = 0;

        for (final task in completed) {
          if (task.type == CourseTaskType.assignment &&
              task.submission?.pointsAwarded != null &&
              task.assignment?.maxPoints != null) {
            totalScore += task.submission!.pointsAwarded!;
            maxPossible += task.assignment!.maxPoints;
          } else if (task.type == CourseTaskType.quiz &&
              task.quizResult?.score != null &&
              task.quiz?.totalMarks != null) {
            totalScore += task.quizResult!.score;
            maxPossible += task.quiz!.totalMarks;
          }
        }

        String averageScoreStr = '-';
        if (maxPossible > 0) {
          double avg = (totalScore / maxPossible) * 100;
          averageScoreStr =
              '${avg.toStringAsFixed(avg.truncateToDouble() == avg ? 0 : 1)}%';
        }

        return ListView(
          padding: EdgeInsets.all(24.w),
          physics: const BouncingScrollPhysics(),
          children: [
            // Top Stats
            CourseExamsStatsRow(
              averageScore: averageScoreStr,
              upcomingTasksCount: upcoming.length,
            ),
            SizedBox(height: 32.h),

            // Upcoming section header
            ExamsSectionHeader(
              title: 'قادم',
              pillText: '${upcoming.length} مهام',
            ),
            SizedBox(height: 16.h),

            if (upcoming.isEmpty)
              const ExamsEmptyUpcomingState()
            else
              ...upcoming.map((task) {
                if (task.type == CourseTaskType.assignment &&
                    task.assignment != null) {
                  return CourseAssignmentCard(
                    assignment: task.assignment!,
                    onSubmitted: () {
                      context
                          .read<CourseExamsCubit>()
                          .fetchExamsAndAssignments(course.id, showLoading: true);
                    },
                  );
                } else if (task.type == CourseTaskType.quiz &&
                    task.quiz != null) {
                  return CourseQuizCard(quiz: task.quiz!);
                }
                return const SizedBox.shrink();
              }),

            if (completed.isNotEmpty) ...[
              SizedBox(height: 32.h),
              ExamsSectionHeader(
                title: 'مكتمل',
                pillText: 'آخر ${completed.length}',
              ),
              SizedBox(height: 16.h),
              ...completed.map((task) {
                if (task.type == CourseTaskType.assignment &&
                    task.assignment != null &&
                    task.submission != null) {
                  return CourseTaskCompletedCard(
                    assignment: task.assignment!,
                    submission: task.submission!,
                  );
                } else if (task.type == CourseTaskType.quiz &&
                    task.quiz != null) {
                  return CourseQuizCompletedCard(
                    quiz: task.quiz!,
                    result: task.quizResult,
                  );
                }
                return const SizedBox.shrink();
              }),
            ],

            SizedBox(height: 40.h),
          ],
        );
      },
    );
  }
}

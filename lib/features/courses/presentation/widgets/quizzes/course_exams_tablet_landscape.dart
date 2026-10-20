import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_exams/course_exams_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_exams/course_exams_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/course_tablet_assignment_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/completed_cards/course_tablet_task_completed_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/course_exams_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/course_exams_tablet_empty_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/course_exams_tablet_section_header.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/course_exams_tablet_stats_row.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/course_tablet_quiz_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/course_tablet_quiz_completed_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/course_tasks_two_column_grid.dart';

/// Dedicated Tablet Landscape layout for [CourseExamsScreen].
class CourseExamsTabletLandscape extends StatelessWidget {
  final CourseDetail course;

  const CourseExamsTabletLandscape({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 24.0;

    return SafeArea(
      child: BlocBuilder<CourseExamsCubit, CourseExamsState>(
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fixed Top Bar with back button and screen title
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 8.0,
                ),
                child: CourseDetailTabletTopBar(title: 'الامتحانات والواجبات'),
              ),

              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 4.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Stats Row
                CourseExamsTabletStatsRow(
                  averageScore: averageScoreStr,
                  upcomingTasksCount: upcoming.length,
                ),

                const SizedBox(height: 24),

                // Upcoming Section Header
                CourseExamsTabletSectionHeader(
                  title: 'قادم',
                  pillText: '${upcoming.length} مهام',
                ),

                const SizedBox(height: 14),

                // Upcoming Tasks in 2 Columns
                if (upcoming.isEmpty)
                  const CourseExamsTabletEmptyState()
                else
                  CourseTasksTwoColumnGrid(
                    children: upcoming.map((task) {
                      if (task.type == CourseTaskType.assignment &&
                          task.assignment != null) {
                        return CourseTabletAssignmentCard(
                          assignment: task.assignment!,
                          onSubmitted: () {
                            context
                                .read<CourseExamsCubit>()
                                .fetchExamsAndAssignments(
                                  course.id,
                                  showLoading: true,
                                );
                          },
                        );
                      } else if (task.type == CourseTaskType.quiz &&
                          task.quiz != null) {
                        return CourseTabletQuizCard(
                          quiz: task.quiz!,
                          courseId: course.id,
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                  ),

                // Completed Section Header and 2 Columns
                if (completed.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  CourseExamsTabletSectionHeader(
                    title: 'مكتمل',
                    pillText: 'آخر ${completed.length}',
                  ),
                  const SizedBox(height: 14),
                  CourseTasksTwoColumnGrid(
                    children: completed.map((task) {
                      if (task.type == CourseTaskType.assignment &&
                          task.assignment != null &&
                          task.submission != null) {
                        return CourseTabletTaskCompletedCard(
                          assignment: task.assignment!,
                          submission: task.submission!,
                        );
                      } else if (task.type == CourseTaskType.quiz &&
                          task.quiz != null) {
                        return CourseTabletQuizCompletedCard(
                          quiz: task.quiz!,
                          result: task.quizResult,
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

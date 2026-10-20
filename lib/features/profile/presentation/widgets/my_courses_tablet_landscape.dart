import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/widgets/empty_state_widget.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/course_tablet_grid.dart';
import 'package:pythagoras/features/profile/presentation/cubit/my_courses/my_courses_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/my_courses/my_courses_state.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_course_tablet_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_courses_tablet_shimmer.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_courses_tablet_top_bar.dart';

/// Professional Tablet Landscape layout for enrolled courses (My Courses).
/// Renders a fixed top bar and responsive 2-3 column grid of enrolled courses.
class MyCoursesTabletLandscape extends StatelessWidget {
  const MyCoursesTabletLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth >= 1050 ? 3 : 2;

        return BlocBuilder<MyCoursesCubit, MyCoursesState>(
          builder: (context, state) {
            if (state is MyCoursesLoading) {
              return MyCoursesTabletShimmer(columnCount: columnCount);
            } else if (state is MyCoursesError) {
              return NoInternetWidget(
                message: state.message,
                onRetry: () => context.read<MyCoursesCubit>().fetchMyCourses(),
              );
            } else if (state is MyCoursesLoaded) {
              if (state.enrollments.isEmpty) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: MyCoursesTabletTopBar(courseCount: 0),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              SizedBox(height: 60),
                              EmptyStateWidget(
                                icon: Icons.school_outlined,
                                message: 'لا توجد دورات مسجلة حالياً',
                                subMessage:
                                    'تصفح قائمة الدورات واشترك في دوراتك المفضلة للبدء في مسيرتك التعليمية',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              final cards = state.enrollments
                  .map(
                    (enrollment) => MyCourseTabletCard(enrollment: enrollment),
                  )
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: MyCoursesTabletTopBar(
                      courseCount: state.enrollments.length,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CourseTabletGrid(
                            columnCount: columnCount,
                            spacing: 18,
                            children: cards,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

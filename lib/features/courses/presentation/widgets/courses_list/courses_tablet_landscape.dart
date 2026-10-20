import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/widgets/empty_state_widget.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/courses_tablet_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/course_tablet_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/course_tablet_grid.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/courses_tablet_error_widget.dart';
import 'package:pythagoras/features/courses/presentation/widgets/filters/course_tablet_filter_bar.dart';

/// Professional Tablet Landscape layout for Courses screen.
/// Balanced top toolbar with Title and Capsule Filter Pills, with immediate course grid.
class CoursesTabletLandscape extends StatefulWidget {
  final double bottomPadding;

  const CoursesTabletLandscape({super.key, this.bottomPadding = 24});

  @override
  State<CoursesTabletLandscape> createState() => _CoursesTabletLandscapeState();
}

class _CoursesTabletLandscapeState extends State<CoursesTabletLandscape> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<CoursesListCubit>();
    if (cubit.state is CoursesListInitial) {
      cubit.fetchCourses();
    }
  }

  void _onCourseTap(dynamic course) {
    context.push(
      Routes.courseDetailScreen,
      extra: {
        'id': course.id,
        'title': course.title,
        'isEnrolled': course.isEnrolled,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth >= 1050 ? 3 : 2;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header Row: Title on right, Capsule Filters on left
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      'الدورات',
                      style: font20w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                        fontSize: 22,
                      ),
                    ),
                    const CourseTabletFilterBar(),
                  ],
                ),
              ),

              // Courses List / Grid directly visible
              Expanded(
                child: BlocBuilder<CoursesListCubit, CoursesListState>(
                  builder: (context, state) {
                    if (state is CoursesListLoading ||
                        state is CoursesListInitial) {
                      return CoursesTabletShimmer(
                        columnCount: columnCount,
                        bottomPadding: widget.bottomPadding,
                      );
                    } else if (state is CoursesListError) {
                      return CoursesTabletErrorWidget(
                        message: state.message,
                        onRetry: () =>
                            context.read<CoursesListCubit>().fetchCourses(),
                      );
                    } else if (state is CoursesListLoaded) {
                      if (state.courses.isEmpty) {
                        return const Center(
                          child: EmptyStateWidget(
                            message: 'لا توجد دورات متاحة حالياً',
                            subMessage: 'جرب تغيير الفلتر أو حاول في وقت لاحق',
                            icon: Icons.school_outlined,
                          ),
                        );
                      }

                      final cardWidgets = state.courses.map((course) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: CourseTabletCard(
                            course: course,
                            onTap: () => _onCourseTap(course),
                          ),
                        );
                      }).toList();

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            CourseTabletGrid(
                              columnCount: columnCount,
                              spacing: 18,
                              children: cardWidgets,
                            ),
                            SizedBox(height: widget.bottomPadding),
                          ],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

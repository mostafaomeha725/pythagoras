import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/widgets/empty_state_widget.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_card/course_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_page_header.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/courses_error_widget.dart';
import 'package:pythagoras/features/courses/presentation/widgets/filters/courses_filter_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_card/course_shimmer_list.dart';

class CoursesScreenBody extends StatefulWidget {
  const CoursesScreenBody({super.key});

  @override
  State<CoursesScreenBody> createState() => _CoursesScreenBodyState();
}

class _CoursesScreenBodyState extends State<CoursesScreenBody> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),

            // Header
            const CoursePageHeader(title: 'الدورات'),

            SizedBox(height: 24.h),

            // Filters
            const CoursesFilterBar(),

            SizedBox(height: 24.h),

            // Courses List
            BlocBuilder<CoursesListCubit, CoursesListState>(
              builder: (context, state) {
                if (state is CoursesListLoading) {
                  return const CourseShimmerList(count: 6);
                } else if (state is CoursesListError) {
                  return CoursesErrorWidget(
                    message: state.message,
                    onRetry: () =>
                        context.read<CoursesListCubit>().fetchCourses(),
                  );
                } else if (state is CoursesListLoaded) {
                  if (state.courses.isEmpty) {
                    return const EmptyStateWidget(
                      message: 'لا توجد دورات متاحة حالياً',
                      subMessage: 'جرب تغيير الفلتر أو حاول في وقت لاحق',
                      icon: Icons.school_outlined,
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.courses.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final course = state.courses[index];
                      return CourseCard(
                        course: course,
                        onTap: () => context.push(
                          Routes.courseDetailScreen,
                          extra: {
                            'id': course.id, 
                            'title': course.title, 
                            'isEnrolled': course.isEnrolled,
                          },
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            SizedBox(height: 120.h), // Extra padding for Bottom Navigation Bar
          ],
        ),
      ),
    );
  }
}

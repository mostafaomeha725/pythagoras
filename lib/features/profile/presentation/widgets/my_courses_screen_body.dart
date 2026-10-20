import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/presentation/cubit/my_courses/my_courses_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/my_courses/my_courses_state.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_course_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_courses_shimmer.dart';

import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_courses_tablet_landscape.dart';

class MyCoursesScreenBody extends StatelessWidget {
  const MyCoursesScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet =
            ResponsiveHelper.isTablet(context) ||
            (constraints.maxWidth >= 900 &&
                constraints.maxWidth > constraints.maxHeight);

        if (isTablet) {
          return const MyCoursesTabletLandscape();
        }

        return BlocBuilder<MyCoursesCubit, MyCoursesState>(
          builder: (context, state) {
            if (state is MyCoursesLoading) {
              return const MyCoursesShimmer();
            } else if (state is MyCoursesError) {
              return NoInternetWidget(
                message: state.message,
                onRetry: () => context.read<MyCoursesCubit>().fetchMyCourses(),
              );
            } else if (state is MyCoursesLoaded) {
              if (state.enrollments.isEmpty) {
                return Center(
                  child: AppText(
                    'لا توجد دورات مسجلة',
                    style: font16w700,
                    alignment: AlignmentDirectional.center,
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(24.w),
                physics: const BouncingScrollPhysics(),
                itemCount: state.enrollments.length,
                itemBuilder: (context, index) =>
                    MyCourseCard(enrollment: state.enrollments[index]),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

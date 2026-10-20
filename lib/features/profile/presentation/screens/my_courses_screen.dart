import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/profile/presentation/cubit/my_courses/my_courses_cubit.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_courses_screen_body.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MyCoursesCubit>()..fetchMyCourses(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet =
              ResponsiveHelper.isTablet(context) ||
              (constraints.maxWidth >= 900 &&
                  constraints.maxWidth > constraints.maxHeight);

          return Scaffold(
            appBar: isTablet
                ? null
                : const CourseDetailAppBar(title: 'دوراتي / الاشتراكات'),
            body: const SafeArea(child: MyCoursesScreenBody()),
          );
        },
      ),
    );
  }
}

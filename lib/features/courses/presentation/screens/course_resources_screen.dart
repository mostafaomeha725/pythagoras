import 'package:flutter/material.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_resources_screen_body.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_resources_tablet_landscape.dart';

class CourseResourcesScreen extends StatelessWidget {
  final CourseDetail course;

  const CourseResourcesScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = ResponsiveHelper.isTablet(context) ||
            (constraints.maxWidth >= 900 &&
                constraints.maxWidth > constraints.maxHeight);

        if (isTablet) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: SafeArea(
              child: CourseResourcesTabletLandscape(course: course),
            ),
          );
        }

        // Original layout for Mobile Portrait & Mobile Landscape completely untouched
        return Scaffold(
          appBar: const CourseDetailAppBar(title: 'الموارد'),
          body: SafeArea(child: CourseResourcesScreenBody(course: course)),
        );
      },
    );
  }
}

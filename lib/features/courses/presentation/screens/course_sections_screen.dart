import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_sections_screen_body.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';

import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_sections_tablet_landscape.dart';

class CourseSectionsScreen extends StatelessWidget {
  final CourseDetail course;
  final int? selectedChapterId;
  const CourseSectionsScreen({
    super.key,
    required this.course,
    this.selectedChapterId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet =
            ResponsiveHelper.isTablet(context) ||
            (constraints.maxWidth >= 900 &&
                constraints.maxWidth > constraints.maxHeight);

        if (isTablet) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: CourseSectionsTabletLandscape(
              course: course,
              selectedChapterId: selectedChapterId,
            ),
          );
        }

        // Original layout for Mobile Portrait & Tablet Portrait completely untouched
        return Scaffold(
          appBar: const CourseDetailAppBar(title: 'أقسام الدورة'),
          body: SafeArea(
            child: CourseSectionsScreenBody(
              course: course,
              selectedChapterId: selectedChapterId,
            ),
          ),
        );
      },
    );
  }
}

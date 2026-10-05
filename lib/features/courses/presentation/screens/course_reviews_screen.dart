import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_reviews/course_reviews_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/add_course_review/add_course_review_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_screen_body.dart';

class CourseReviewsScreen extends StatelessWidget {
  final int courseId;
  final String courseTitle;

  const CourseReviewsScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<CourseReviewsCubit>()..fetchCourseReviews(courseId),
        ),
        BlocProvider(
          create: (context) => sl<AddCourseReviewCubit>(),
        ),
      ],
      child: Scaffold(
        appBar: const CourseDetailAppBar(title: 'تقييمات الدورة'),
        body: CourseReviewsScreenBody(
          courseId: courseId,
          courseTitle: courseTitle,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_bottom_button.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_screen_body.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailScreen extends StatelessWidget {
  final int courseId;
  final String courseTitle;
  final bool isEnrolled;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.isEnrolled,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<CourseDetailsCubit>()..fetchCourseDetails(courseId),
        ),
        BlocProvider(create: (context) => sl<RequestEnrollmentCubit>()),
      ],
      child: BlocListener<RequestEnrollmentCubit, RequestEnrollmentState>(
        listener: (context, state) async {
          if (state is RequestEnrollmentLoading) {
            EasyLoading.show(status: 'جاري التحميل...');
          } else if (state is RequestEnrollmentSuccess) {
            EasyLoading.dismiss();
            final url = Uri.parse(state.whatsappUrl);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              EasyLoading.showError('لا يمكن فتح الواتساب');
            }
          } else if (state is RequestEnrollmentError) {
            EasyLoading.showError(state.message);
          }
        },

        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: const CourseDetailAppBar(),
        body: BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
            builder: (context, state) {
              if (state is CourseDetailsLoading) {
                return const CourseDetailShimmer();
              } else if (state is CourseDetailsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      ElevatedButton(
                        onPressed: () => context
                            .read<CourseDetailsCubit>()
                            .fetchCourseDetails(courseId),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              } else if (state is CourseDetailsLoaded) {
                // The API might not return the correct isEnrolled for course-details,
                // so we override it with the one passed from the courses list.
                final updatedCourse = state.courseDetail.copyWith(
                  isEnrolled: isEnrolled,
                );

                return Stack(
                  children: [
                    SafeArea(
                      top: false,
                      child: CourseDetailScreenBody(course: updatedCourse),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: CourseDetailBottomButton(
                        course: updatedCourse,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

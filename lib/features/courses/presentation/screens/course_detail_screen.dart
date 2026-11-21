import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_screen_content.dart';

class CourseDetailScreen extends StatefulWidget {
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
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with WidgetsBindingObserver {
  late final CourseDetailsCubit _courseDetailsCubit;
  late final RequestEnrollmentCubit _requestEnrollmentCubit;
  late final RemoteConfigCubit _remoteConfigCubit;
  late final AppleIapCubit _appleIapCubit;
  bool _isWaitingForWhatsApp = false;

  @override
  void initState() {
    super.initState();
    _courseDetailsCubit = sl<CourseDetailsCubit>()
      ..fetchCourseDetails(widget.courseId);
    _requestEnrollmentCubit = sl<RequestEnrollmentCubit>();
    _remoteConfigCubit = sl<RemoteConfigCubit>()..load();
    _appleIapCubit = sl<AppleIapCubit>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _courseDetailsCubit.close();
    _requestEnrollmentCubit.close();
    _remoteConfigCubit.close();
    _appleIapCubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isWaitingForWhatsApp) {
      _isWaitingForWhatsApp = false;
      _courseDetailsCubit.fetchCourseDetails(widget.courseId);
      if (mounted) {
        context.read<CoursesListCubit>().fetchCourses();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletLandscape =
            constraints.maxWidth >= 900 &&
            constraints.maxHeight >= 600 &&
            constraints.maxWidth > constraints.maxHeight;

        return Scaffold(
          backgroundColor: isTabletLandscape
              ? const Color(0xFFF8F9FA)
              : Colors.white,
          appBar: isTabletLandscape ? null : const CourseDetailAppBar(),
          body: CourseDetailScreenContent(
            courseId: widget.courseId,
            courseDetailsCubit: _courseDetailsCubit,
            requestEnrollmentCubit: _requestEnrollmentCubit,
            remoteConfigCubit: _remoteConfigCubit,
            appleIapCubit: _appleIapCubit,
            onWhatsAppLaunched: (launched) {
              if (launched) {
                setState(() => _isWaitingForWhatsApp = true);
              }
            },
          ),
        );
      },
    );
  }
}

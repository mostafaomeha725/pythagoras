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
import 'package:pythagoras/features/courses/presentation/cubit/direct_request/direct_request_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/direct_request/direct_request_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_shimmer.dart';
import 'package:pythagoras/core/utils/url_launcher_util.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';

import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_landscape.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_shimmer.dart';

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
  late final DirectRequestCubit _directRequestCubit;
  bool _isWaitingForWhatsApp = false;

  @override
  void initState() {
    super.initState();
    _courseDetailsCubit = sl<CourseDetailsCubit>()
      ..fetchCourseDetails(widget.courseId);
    _requestEnrollmentCubit = sl<RequestEnrollmentCubit>();
    _directRequestCubit = sl<DirectRequestCubit>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _courseDetailsCubit.close();
    _requestEnrollmentCubit.close();
    _directRequestCubit.close();
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _courseDetailsCubit),
        BlocProvider.value(value: _requestEnrollmentCubit),
        BlocProvider.value(value: _directRequestCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          // ── Android: WhatsApp redirect flow (unchanged) ──────────────────
          BlocListener<RequestEnrollmentCubit, RequestEnrollmentState>(
            listener: (context, state) async {
              if (state is RequestEnrollmentLoading) {
                EasyLoading.show(status: 'جاري التحميل...');
              } else if (state is RequestEnrollmentSuccess) {
                EasyLoading.dismiss();
                final launched = await UrlLauncherUtil.openWhatsAppUrl(
                  state.whatsappUrl,
                  chapterTitle: state.chapterTitle,
                  courseTitle: state.courseTitle,
                  isChapter: state.isChapter,
                );
                if (launched) {
                  _isWaitingForWhatsApp = true;
                } else {
                  EasyLoading.showError(
                    'تعذر فتح الواتساب، يرجى التأكد من تثبيت التطبيق',
                  );
                }
              } else if (state is RequestEnrollmentError) {
                EasyLoading.showError(state.message);
              }
            },
          ),
          // ── iOS: direct enrollment flow ──────────────────────────────────
          BlocListener<DirectRequestCubit, DirectRequestState>(
            listener: (context, state) {
              if (state is DirectRequestLoading) {
                EasyLoading.show(status: 'جاري التحميل...');
              } else if (state is DirectRequestSuccess) {
                EasyLoading.showSuccess(state.message);
                // Refresh course details and courses list immediately after
                // a successful iOS direct request — mirrors the same two
                // calls Android makes when the app returns from WhatsApp
                // (see didChangeAppLifecycleState).
                _courseDetailsCubit.fetchCourseDetails(widget.courseId);
                if (mounted) {
                  context.read<CoursesListCubit>().fetchCourses();
                }
              } else if (state is DirectRequestError) {
                EasyLoading.showError(state.message);
              }
            },
          ),
        ],

        child: LayoutBuilder(
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
              body: BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
                builder: (context, state) {
                  if (state is CourseDetailsLoading) {
                    if (isTabletLandscape) {
                      return CourseDetailTabletShimmer(
                        constraints: constraints,
                      );
                    }
                    return const CourseDetailShimmer();
                  } else if (state is CourseDetailsError) {
                    return NoInternetWidget(
                      message: state.message,
                      onRetry: () => _courseDetailsCubit.fetchCourseDetails(
                        widget.courseId,
                      ),
                    );
                  } else if (state is CourseDetailsLoaded) {
                    final updatedCourse = state.courseDetail;

                    // ── Tablet Landscape: dedicated two-column layout ──
                    if (isTabletLandscape) {
                      return CourseDetailTabletLandscape(
                        course: updatedCourse,
                        constraints: constraints,
                      );
                    }

                    // ── Mobile Portrait & Tablet Portrait: original layout untouched ──
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
            );
          },
        ),
      ),
    );
  }
}

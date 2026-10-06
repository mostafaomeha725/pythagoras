import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/courses/presentation/cubit/chapter_videos/chapter_videos_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/complete_video/complete_video_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/complete_lesson/complete_lesson_cubit.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_recorded_lessons_screen_body.dart';

class CourseRecordedLessonsScreen extends StatelessWidget {
  final CourseDetail course;
  final int? selectedChapterId;

  const CourseRecordedLessonsScreen({
    super.key,
    required this.course,
    this.selectedChapterId,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CourseDetailAppBar(title: 'الدروس المسجلة'),
        body: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => sl<ChapterVideosCubit>()),
            BlocProvider(create: (context) => sl<CompleteVideoCubit>()),
            BlocProvider(create: (context) => sl<CompleteLessonCubit>()),
          ],
          child: SafeArea(
            child: CourseRecordedLessonsScreenBody(
              course: course,
              selectedChapterId: selectedChapterId,
            ),
          ),
        ),
      ),
    );
  }
}

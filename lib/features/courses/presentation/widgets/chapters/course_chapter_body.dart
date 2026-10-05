import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_cubit.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/course_chapter.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_chapter_buy_button.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_lessons_list.dart';

class CourseChapterBody extends StatelessWidget {
  final CourseChapter chapter;
  final bool isEnrolled;
  final bool showActionButtons;
  final bool showLessonStatuses;
  final CourseDetail? course;
  final String? selectedLessonId;
  final Function(CourseLesson)? onLessonTap;

  const CourseChapterBody({
    super.key,
    required this.chapter,
    required this.isEnrolled,
    this.showActionButtons = true,
    this.showLessonStatuses = false,
    this.course,
    this.selectedLessonId,
    this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider removed per user request
        if (isEnrolled || chapter.isEnrolled)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showActionButtons) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                  child: AppButton(
                    text: 'عرض الدرس',
                    onPressed: () {
                      if (course != null) {
                        context.push(
                          Routes.courseSectionsScreen, 
                          extra: {
                            'course': course,
                            'selectedChapterId': chapter.id,
                          },
                        );
                      }
                    },
                    radius: 12.r,
                    height: 48.h,
                    textSize: 15.sp,
                  ),
                ),
                if (chapter.videos.isNotEmpty)
                  Divider(
                    height: 1,
                    color: AppLightColors.primary.withValues(alpha: 0.12),
                    indent: 16.w,
                    endIndent: 16.w,
                  ),
              ],
              if (chapter.videos.isNotEmpty)
                CourseLessonsList(
                  lessons: chapter.videos,
                  showStatuses: showLessonStatuses,
                  selectedLessonId: selectedLessonId,
                  onLessonTap: onLessonTap,
                ),
            ],
          )
        else if (showActionButtons)
          CourseChapterBuyButton(
            price: chapter.price,
            currencyLabel: chapter.currencyLabel,
            isEnrolled: isEnrolled || chapter.isEnrolled,
            onPressed: () {
              context.read<RequestEnrollmentCubit>().requestChapter(chapter.id);
            },
          ),
      ],
    );
  }
}

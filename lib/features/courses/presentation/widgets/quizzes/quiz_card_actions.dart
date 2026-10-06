import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_exams/course_exams_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';

/// Bottom row of [CourseQuizCard]: duration info + start button.
class QuizCardActions extends StatelessWidget {
  final CourseQuiz quiz;

  const QuizCardActions({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 14.sp,
              color: const Color(0xFF9CA3AF),
            ),
            SizedBox(width: 6.w),
            AppText(
              'الوقت: ${quiz.duration} دقيقة',
              style: font12w500.copyWith(color: const Color(0xFF6B7280)),
            ),
          ],
        ),
        InkWell(
          onTap: () async {
            final result = await context.push<bool>(
              Routes.quizScreen,
              extra: quiz,
            );
            if (result == true && context.mounted && quiz.courseId != null) {
              context.read<CourseExamsCubit>().fetchExamsAndAssignments(
                quiz.courseId!,
                showLoading: true,
              );
            }
          },
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF832561),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Row(
              children: [
                const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                SizedBox(width: 8.w),
                AppText(
                  'ابدأ',
                  style: font14w700.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

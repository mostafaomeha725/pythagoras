import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_exams/course_exams_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';

/// Bottom row of [CourseQuizCard]: duration & attempts info + start/retry button.
class QuizCardActions extends StatelessWidget {
  final CourseQuiz quiz;
  final int? courseId;

  const QuizCardActions({super.key, required this.quiz, this.courseId});

  @override
  Widget build(BuildContext context) {
    final bool isFirstAttempt = quiz.isFirstAttempt;
    final String buttonText = isFirstAttempt ? 'ابدأ' : 'حاول مرة أخرى';
    final IconData buttonIcon = isFirstAttempt
        ? Icons.play_arrow_rounded
        : Icons.replay_rounded;
    final int? targetCourseId = courseId ?? quiz.courseId;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
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
              if (quiz.hasAttemptLimit || quiz.remainingAttempts != null) ...[
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.replay_rounded,
                      size: 14.sp,
                      color: const Color(0xFF832561),
                    ),
                    SizedBox(width: 6.w),
                    AppText(
                      quiz.remainingAttemptsLabel,
                      style: font12w700.copyWith(
                        color: const Color(0xFF832561),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        InkWell(
          onTap: () async {
            final result = await context.push<bool>(
              Routes.quizScreen,
              extra: quiz,
            );
            if (result == true && context.mounted && targetCourseId != null) {
              context.read<CourseExamsCubit>().fetchExamsAndAssignments(
                targetCourseId,
                showLoading: true,
              );
            }
          },
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isFirstAttempt ? 24.w : 16.w,
              vertical: 10.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF832561),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(buttonIcon, color: Colors.white, size: 15.sp),
                SizedBox(width: 6.w),
                AppText(
                  buttonText,
                  style: font12w700.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

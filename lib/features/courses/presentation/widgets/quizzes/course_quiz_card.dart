import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_exams/course_exams_cubit.dart';

class CourseQuizCard extends StatelessWidget {
  final CourseQuiz quiz;
  final int? courseId;

  const CourseQuizCard({
    super.key,
    required this.quiz,
    this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFirstAttempt = quiz.isFirstAttempt;
    final String buttonText = isFirstAttempt ? 'ابدأ' : 'حاول مرة أخرى';
    final IconData buttonIcon =
        isFirstAttempt ? Icons.play_arrow_rounded : Icons.replay_rounded;
    final int? targetCourseId = courseId ?? quiz.courseId;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.02),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      quiz.title,
                      style: font16w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 8.h),
                    if (quiz.description != null &&
                        quiz.description!.isNotEmpty) ...[
                      AppText(
                        quiz.description!,
                        style: font12w500.copyWith(
                          color: const Color(0xFF6B7280),
                          height: 1.4,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isFirstAttempt
                      ? const Color(0xFFFFF9E6)
                      : const Color(0xFFFDF4FA),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: AppText(
                  isFirstAttempt ? 'قادم' : 'إعادة محاولة',
                  style: font12w700.copyWith(
                    color: isFirstAttempt
                        ? const Color(0xFFD97706)
                        : const Color(0xFF832561),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
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
                          style: font12w500.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    if (quiz.hasAttemptLimit ||
                        quiz.remainingAttempts != null) ...[
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
                  if (result == true &&
                      context.mounted &&
                      targetCourseId != null) {
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
                      Icon(
                        buttonIcon,
                        color: Colors.white,
                        size: 15.sp,
                      ),
                      SizedBox(width: 6.w),
                      AppText(
                        buttonText,
                        style: (isFirstAttempt ? font13w700 : font12w700)
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

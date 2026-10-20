import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_exams/course_exams_cubit.dart';

/// Upcoming Quiz Card optimized for Tablet Landscape.
/// Uses explicit typography and paddings to prevent ScreenUtil scaling blowups.
class CourseTabletQuizCard extends StatelessWidget {
  final CourseQuiz quiz;
  final int? courseId;

  const CourseTabletQuizCard({
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and Status Pill
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
                        fontSize: 16,
                      ),
                      maxLines: 2,
                    ),
                    if (quiz.description != null &&
                        quiz.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      AppText(
                        quiz.description!,
                        style: font12w500.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isFirstAttempt
                      ? const Color(0xFFFFF9E6)
                      : const Color(0xFFFDF4FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: AppText(
                  isFirstAttempt ? 'قادم' : 'إعادة محاولة',
                  style: font12w700.copyWith(
                    color: isFirstAttempt
                        ? const Color(0xFFD97706)
                        : const Color(0xFF832561),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Bottom Row: Time info & Action button
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
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 5),
                        AppText(
                          'الوقت: ${quiz.duration} دقيقة',
                          style: font12w500.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (quiz.hasAttemptLimit ||
                        quiz.remainingAttempts != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.replay_rounded,
                            size: 14,
                            color: Color(0xFF832561),
                          ),
                          const SizedBox(width: 5),
                          AppText(
                            quiz.remainingAttemptsLabel,
                            style: font12w700.copyWith(
                              color: const Color(0xFF832561),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
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
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF832561),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        buttonIcon,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      AppText(
                        buttonText,
                        style: font12w700.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
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

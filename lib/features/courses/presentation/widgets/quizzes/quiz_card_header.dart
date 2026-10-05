import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Title, description, and "قادم" pill row for [CourseQuizCard].
class QuizCardHeader extends StatelessWidget {
  final String title;
  final String? description;

  const QuizCardHeader({super.key, required this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                style: font16w700.copyWith(color: const Color(0xFF1E1E2D)),
                maxLines: 2,
              ),
              SizedBox(height: 8.h),
              if (description != null && description!.isNotEmpty) ...[
                AppText(
                  description!,
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
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: AppText(
            'قادم',
            style: font12w700.copyWith(color: const Color(0xFFD97706)),
          ),
        ),
      ],
    );
  }
}

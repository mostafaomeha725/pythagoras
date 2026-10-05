import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/domain/entities/online_lesson.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/online_lesson_card_header.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/online_lesson_card_details.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/online_lesson_card_actions.dart';

class OnlineLessonCard extends StatelessWidget {
  final OnlineLesson lesson;

  const OnlineLessonCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final isLive = lesson.status == OnlineLessonStatus.live;
    final borderColor = isLive ? const Color(0xFFFCA5A5) : const Color(0xFFE5E7EB);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnlineLessonCardHeader(lesson: lesson),
          SizedBox(height: 24.h),
          OnlineLessonCardDetails(lesson: lesson),
          SizedBox(height: 24.h),
          OnlineLessonCardActions(lesson: lesson),
        ],
      ),
    );
  }
}

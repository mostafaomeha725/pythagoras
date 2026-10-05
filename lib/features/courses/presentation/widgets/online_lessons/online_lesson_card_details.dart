import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/domain/entities/online_lesson.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/online_lesson_detail_item.dart';

class OnlineLessonCardDetails extends StatelessWidget {
  final OnlineLesson lesson;

  const OnlineLessonCardDetails({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        OnlineLessonDetailItem(
          text: lesson.dateString,
          icon: Icons.calendar_today_outlined,
        ),
        SizedBox(width: 16.w),
        OnlineLessonDetailItem(
          text: lesson.timeString,
          icon: Icons.access_time_rounded,
        ),
      ],
    );
  }
}

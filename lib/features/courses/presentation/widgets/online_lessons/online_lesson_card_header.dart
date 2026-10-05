import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/online_lesson.dart';

class OnlineLessonCardHeader extends StatelessWidget {
  final OnlineLesson lesson;

  const OnlineLessonCardHeader({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final isLive = lesson.status == OnlineLessonStatus.live;
    final pillBgColor = isLive ? const Color(0xFFFEF2F2) : const Color(0xFFF6EEF5);
    final pillTextColor = isLive ? const Color(0xFFEF4444) : AppLightColors.primary;
    final pillText = isLive ? 'مباشر الآن' : 'قادمة';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title and Subject
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: AppText(
                            lesson.title,
                            style: font16w700.copyWith(color: const Color(0xFF1E1E2D)),
                            textAlign: TextAlign.start,
                            maxLines: 2,
                          ),
                        ),
                        if (isLive)
                          PositionedDirectional(
                            top: 0,
                            start: -6.w,
                            child: Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              AppText(
                lesson.subject,
                style: font12w700.copyWith(color: AppLightColors.primary),
                maxLines: 2,
              ),
            ],
          ),
        ),
        // Pill
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: pillBgColor,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: AppText(
            pillText,
            style: font12w700.copyWith(color: pillTextColor),
          ),
        ),
      ],
    );
  }
}

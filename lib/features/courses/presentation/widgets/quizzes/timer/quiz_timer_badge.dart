import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/timer/quiz_timer_style.dart';

/// Digital countdown badge pill displaying the remaining time.
class QuizTimerBadge extends StatelessWidget {
  final int remainingSeconds;
  final QuizTimerTheme theme;

  const QuizTimerBadge({
    super.key,
    required this.remainingSeconds,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 7.h,
      ),
      decoration: BoxDecoration(
        color: theme.badgeBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: theme.badgeBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hourglass_bottom_rounded,
            color: theme.accentColor,
            size: 15.sp,
          ),
          SizedBox(width: 6.w),
          AppText(
            formatQuizDuration(remainingSeconds),
            style: font14w700.copyWith(
              color: theme.accentColor,
              letterSpacing: 1.0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

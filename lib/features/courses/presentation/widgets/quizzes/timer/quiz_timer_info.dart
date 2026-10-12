import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/timer/quiz_timer_style.dart';

/// Left section of the quiz timer header containing the icon, title, and alert message.
class QuizTimerInfo extends StatelessWidget {
  final QuizTimerTheme theme;

  const QuizTimerInfo({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: theme.badgeBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              theme.timerIcon,
              color: theme.accentColor,
              size: 20.sp,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'الوقت المتبقي',
              style: font12w500.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            if (theme.warningMessage != null)
              AppText(
                theme.warningMessage!,
                style: theme.isCritical
                    ? font10w700.copyWith(
                        color: const Color(0xFFDC2626),
                      )
                    : font10w500.copyWith(
                        color: const Color(0xFFD97706),
                      ),
              ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';

/// Formats duration in seconds to MM:SS or HH:MM:SS format.
String formatQuizDuration(int seconds) {
  final int hours = seconds ~/ 3600;
  final int minutes = (seconds % 3600) ~/ 60;
  final int secs = seconds % 60;

  final String minStr = minutes.toString().padLeft(2, '0');
  final String secStr = secs.toString().padLeft(2, '0');

  if (hours > 0) {
    final String hrStr = hours.toString().padLeft(2, '0');
    return '$hrStr:$minStr:$secStr';
  }
  return '$minStr:$secStr';
}

/// Represents the dynamic theme and styling tokens for the quiz timer.
class QuizTimerTheme {
  final Color accentColor;
  final Color badgeBg;
  final Color badgeBorder;
  final IconData timerIcon;
  final String? warningMessage;
  final bool isCritical;
  final bool isWarning;

  const QuizTimerTheme({
    required this.accentColor,
    required this.badgeBg,
    required this.badgeBorder,
    required this.timerIcon,
    this.warningMessage,
    required this.isCritical,
    required this.isWarning,
  });

  factory QuizTimerTheme.fromSeconds(int remainingSeconds) {
    final bool isCritical = remainingSeconds <= 60;
    final bool isWarning = remainingSeconds <= 300 && !isCritical;

    final Color accentColor = isCritical
        ? const Color(0xFFDC2626)
        : (isWarning ? const Color(0xFFD97706) : AppLightColors.primary);

    final Color badgeBg = isCritical
        ? const Color(0xFFFEF2F2)
        : (isWarning
            ? const Color(0xFFFFFBEB)
            : AppLightColors.primary.withValues(alpha: 0.08));

    final Color badgeBorder = isCritical
        ? const Color(0xFFFECACA)
        : (isWarning
            ? const Color(0xFFFDE68A)
            : AppLightColors.primary.withValues(alpha: 0.2));

    final IconData timerIcon = isCritical
        ? Icons.alarm_on_rounded
        : (isWarning ? Icons.alarm_rounded : Icons.timer_outlined);

    final String? warningMessage = isCritical
        ? 'أسرع، قارب الوقت على الانتهاء!'
        : (isWarning ? 'متبقي أقل من 5 دقائق' : null);

    return QuizTimerTheme(
      accentColor: accentColor,
      badgeBg: badgeBg,
      badgeBorder: badgeBorder,
      timerIcon: timerIcon,
      warningMessage: warningMessage,
      isCritical: isCritical,
      isWarning: isWarning,
    );
  }
}

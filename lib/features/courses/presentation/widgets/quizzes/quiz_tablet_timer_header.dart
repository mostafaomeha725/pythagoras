import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/timer/quiz_timer_progress_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/timer/quiz_timer_style.dart';

/// Countdown timer header optimized for Tablet Landscape.
/// Uses explicit dimensions and typography without ScreenUtil scaling.
class QuizTabletTimerHeader extends StatefulWidget {
  final int initialSeconds;
  final bool isPaused;
  final VoidCallback onTimeExpired;

  const QuizTabletTimerHeader({
    super.key,
    required this.initialSeconds,
    required this.onTimeExpired,
    this.isPaused = false,
  });

  @override
  State<QuizTabletTimerHeader> createState() => _QuizTabletTimerHeaderState();
}

class _QuizTabletTimerHeaderState extends State<QuizTabletTimerHeader> {
  late int _remainingSeconds;
  late int _totalSeconds;
  Timer? _timer;
  bool _hasFiredExpired = false;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.initialSeconds > 0 ? widget.initialSeconds : 1;
    _remainingSeconds = _totalSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant QuizTabletTimerHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSeconds > 0 &&
        (oldWidget.initialSeconds - widget.initialSeconds).abs() > 30 &&
        !_hasFiredExpired) {
      setState(() {
        _totalSeconds = widget.initialSeconds;
        _remainingSeconds = widget.initialSeconds;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (widget.isPaused) return;

      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
        if (!_hasFiredExpired) {
          _hasFiredExpired = true;
          widget.onTimeExpired();
        }
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = QuizTimerTheme.fromSeconds(_remainingSeconds);
    final double progress =
        (_remainingSeconds / (_totalSeconds > 0 ? _totalSeconds : 1))
            .clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFF0F0F0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.badgeBg,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          theme.timerIcon,
                          color: theme.accentColor,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'الوقت المتبقي',
                          style: font12w500.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                        if (theme.warningMessage != null)
                          AppText(
                            theme.warningMessage!,
                            style: theme.isCritical
                                ? font10w700.copyWith(
                                    color: const Color(0xFFDC2626),
                                    fontSize: 10,
                                  )
                                : font10w500.copyWith(
                                    color: const Color(0xFFD97706),
                                    fontSize: 10,
                                  ),
                          ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.badgeBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.badgeBorder, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.hourglass_bottom_rounded,
                        color: theme.accentColor,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      AppText(
                        formatQuizDuration(_remainingSeconds),
                        style: font14w700.copyWith(
                          color: theme.accentColor,
                          letterSpacing: 1.0,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          QuizTimerProgressBar(
            progress: progress,
            accentColor: theme.accentColor,
          ),
        ],
      ),
    );
  }
}

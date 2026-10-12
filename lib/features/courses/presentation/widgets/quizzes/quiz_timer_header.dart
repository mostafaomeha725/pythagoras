import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/timer/quiz_timer_badge.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/timer/quiz_timer_info.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/timer/quiz_timer_progress_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/timer/quiz_timer_style.dart';

/// Pinned, professional countdown timer header for the quiz screen.
/// Displays remaining time in minutes and seconds (MM:SS) and dynamic urgency states.
class QuizTimerHeader extends StatefulWidget {
  final int initialSeconds;
  final bool isPaused;
  final VoidCallback onTimeExpired;

  const QuizTimerHeader({
    super.key,
    required this.initialSeconds,
    required this.onTimeExpired,
    this.isPaused = false,
  });

  @override
  State<QuizTimerHeader> createState() => _QuizTimerHeaderState();
}

class _QuizTimerHeaderState extends State<QuizTimerHeader> {
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
  void didUpdateWidget(covariant QuizTimerHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the server attempt reports a significantly lower remaining time (e.g. existing attempt resumption)
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
            blurRadius: 10,
            offset: const Offset(0, 3),
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
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                QuizTimerInfo(theme: theme),
                QuizTimerBadge(
                  remainingSeconds: _remainingSeconds,
                  theme: theme,
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

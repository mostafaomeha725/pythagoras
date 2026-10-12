import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Slim linear progress indicator showing remaining time percentage with dynamic colors.
class QuizTimerProgressBar extends StatelessWidget {
  final double progress;
  final Color accentColor;

  const QuizTimerProgressBar({
    super.key,
    required this.progress,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 3.h,
        backgroundColor: const Color(0xFFF3F4F6),
        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
      ),
    );
  }
}

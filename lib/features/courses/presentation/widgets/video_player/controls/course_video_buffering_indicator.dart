import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../adapters/course_video_adapter.dart';

class CourseVideoBufferingIndicator extends StatelessWidget {
  final CourseVideoAdapter adapter;

  const CourseVideoBufferingIndicator({super.key, required this.adapter});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: adapter,
      builder: (context, child) {
        return IgnorePointer(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 110),
              reverseDuration: const Duration(milliseconds: 80),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final scale = Tween<double>(begin: 0.88, end: 1).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  ),
                );
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: scale, child: child),
                );
              },
              child: adapter.isBuffering
                  ? const _FastBufferingSpinner(
                      key: ValueKey('course-video-buffering'),
                    )
                  : const SizedBox.shrink(key: ValueKey('course-video-idle')),
            ),
          ),
        );
      },
    );
  }
}

class _FastBufferingSpinner extends StatefulWidget {
  const _FastBufferingSpinner({super.key});

  @override
  State<_FastBufferingSpinner> createState() => _FastBufferingSpinnerState();
}

class _FastBufferingSpinnerState extends State<_FastBufferingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..repeat();

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('course-video-buffering-spinner'),
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.68),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: RotationTransition(
        turns: _rotationController,
        child: CustomPaint(
          size: const Size.square(28),
          painter: _BufferingRingPainter(),
        ),
      ),
    );
  }
}

class _BufferingRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 2.6;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final activePaint = Paint()
      ..color = const Color(0xFF61B5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 1.25, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _BufferingRingPainter oldDelegate) => false;
}

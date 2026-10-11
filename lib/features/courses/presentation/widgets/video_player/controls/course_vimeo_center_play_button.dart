import 'package:flutter/material.dart';
import '../adapters/course_video_adapter.dart';

class CourseVimeoCenterPlayButton extends StatelessWidget {
  final CourseVideoAdapter adapter;
  final bool showCustomControls;

  const CourseVimeoCenterPlayButton({
    super.key,
    required this.adapter,
    required this.showCustomControls,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: adapter,
        builder: (context, child) {
          if (!showCustomControls) {
            return const SizedBox.shrink();
          }
          return GestureDetector(
            onTap: () {
              if (adapter.isPlaying) {
                adapter.pause();
              } else {
                adapter.play();
              }
            },
            child: Container(
              width: 72.0,
              height: 72.0,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                adapter.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 48.0,
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../adapters/course_video_adapter.dart';

class CourseVideoBufferingIndicator extends StatelessWidget {
  final CourseVideoAdapter adapter;

  const CourseVideoBufferingIndicator({
    super.key,
    required this.adapter,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: adapter,
      builder: (context, child) {
        if (adapter.isBuffering && !adapter.isPlaying) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../adapters/course_video_adapter.dart';

class CourseVideoCenterControl extends StatelessWidget {
  static const _surfaceSize = 60.0;
  static const _iconSize = 44.0;

  final CourseVideoAdapter adapter;
  final bool visible;

  const CourseVideoCenterControl({
    super.key,
    required this.adapter,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Center(
      child: AnimatedBuilder(
        animation: adapter,
        builder: (context, child) {
          return Material(
            key: const ValueKey('course-video-center-control-surface'),
            color: Colors.black.withValues(alpha: 0.38),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: Semantics(
              button: true,
              label: adapter.isPlaying ? 'إيقاف الفيديو' : 'تشغيل الفيديو',
              child: InkWell(
                onTap: adapter.togglePlayPause,
                customBorder: const CircleBorder(),
                child: SizedBox.square(
                  dimension: _surfaceSize,
                  child: Center(
                    child: SizedBox.square(
                      dimension: _iconSize,
                      child: adapter.isPlaying
                          ? const Icon(
                              Icons.pause,
                              color: Colors.white,
                              size: _iconSize,
                            )
                          : Transform.scale(
                              scale: 1.05,
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: _iconSize,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import '../adapters/course_video_adapter.dart';

class CourseVideoBottomControls extends StatelessWidget {
  final CourseVideoAdapter adapter;
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;

  const CourseVideoBottomControls({
    super.key,
    required this.adapter,
    required this.isFullScreen,
    required this.onToggleFullScreen,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedBuilder(
        animation: adapter,
        builder: (context, child) {
          final replayButton = GestureDetector(
            onTap: () {
              adapter.seekTo(
                adapter.position - const Duration(seconds: 10),
              );
            },
            child: const Icon(
              Icons.replay_10,
              color: Colors.white,
              size: 24.0,
            ),
          );

          final forwardButton = GestureDetector(
            onTap: () {
              adapter.seekTo(
                adapter.position + const Duration(seconds: 10),
              );
            },
            child: const Icon(
              Icons.forward_10,
              color: Colors.white,
              size: 24.0,
            ),
          );

          final timeText =
              adapter.supportsPosition && adapter.supportsDuration
                  ? AppText(
                      '${_formatDuration(adapter.position)} / ${_formatDuration(adapter.duration)}',
                      style: font12w400.copyWith(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox.shrink();

          final volumeButton = adapter.supportsVolume
              ? GestureDetector(
                  onTap: () {
                    adapter.toggleMute();
                  },
                  child: Icon(
                    adapter.volume == 0
                        ? Icons.volume_off
                        : Icons.volume_up,
                    color: Colors.white,
                    size: 22.0,
                  ),
                )
              : const SizedBox.shrink();

          final fullscreenBtn = GestureDetector(
            onTap: onToggleFullScreen,
            child: Icon(
              isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              color: Colors.white,
              size: 24.0,
            ),
          );

          final playPauseButton = GestureDetector(
            onTap: () {
              if (adapter.isPlaying) {
                adapter.pause();
              } else {
                adapter.play();
              }
            },
            child: Icon(
              adapter.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 28.0,
            ),
          );

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (adapter.supportsSeek) ...[
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14.0,
                      ),
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: Colors.white.withValues(
                        alpha: 0.3,
                      ),
                      thumbColor: Colors.blue,
                    ),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Slider(
                        value: (adapter.duration.inMilliseconds > 0)
                            ? (adapter.position.inMilliseconds /
                                    adapter.duration.inMilliseconds)
                                .clamp(0.0, 1.0)
                            : 0.0,
                        onChanged: (value) {
                          final newPos = Duration(
                            milliseconds: (value *
                                    adapter.duration.inMilliseconds)
                                .toInt(),
                          );
                          adapter.seekTo(newPos);
                        },
                      ),
                    ),
                  ),
                ],
                Row(
                  children: [
                    fullscreenBtn,
                    if (adapter.supportsVolume) ...[
                      const SizedBox(width: 12.0),
                      volumeButton,
                    ],
                    const SizedBox(width: 12.0),
                    Expanded(child: timeText),
                    if (adapter.supportsSeek) ...[
                      forwardButton,
                      const SizedBox(width: 8.0),
                      replayButton,
                    ],
                    const SizedBox(width: 12.0),
                    playPauseButton,
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

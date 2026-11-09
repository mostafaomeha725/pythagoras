import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
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
            onTap: () => adapter.seekBy(const Duration(seconds: -10)),
            child: const Icon(Icons.replay_10, color: Colors.white, size: 24.0),
          );

          final forwardButton = GestureDetector(
            onTap: () => adapter.seekBy(const Duration(seconds: 10)),
            child: const Icon(
              Icons.forward_10,
              color: Colors.white,
              size: 24.0,
            ),
          );

          final isTablet = ResponsiveHelper.isTablet(context);
          final displayedPosition =
              adapter.pendingSeekPosition ?? adapter.position;

          final timeText = adapter.supportsPosition && adapter.supportsDuration
              ? AppText(
                  '${_formatDuration(displayedPosition)} / ${_formatDuration(adapter.duration)}',
                  style: isTablet
                      ? font12w400.copyWith(color: Colors.white, fontSize: 13)
                      : font12w400.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                )
              : const SizedBox.shrink();

          final volumeButton = adapter.supportsVolume
              ? IconButton(
                  tooltip: adapter.isMuted ? 'إلغاء كتم الصوت' : 'كتم الصوت',
                  onPressed: adapter.toggleMute,
                  icon: Icon(
                    adapter.isMuted ? Icons.volume_off : Icons.volume_up,
                    color: adapter.isMuted ? Colors.white70 : Colors.white,
                  ),
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
                )
              : const SizedBox.shrink();

          final fullscreenBtn = GestureDetector(
            onTap: onToggleFullScreen,
            child: Icon(
              isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
              size: 24.0,
            ),
          );

          final playPauseButton = GestureDetector(
            onTap: adapter.togglePlayPause,
            child: Icon(
              adapter.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32.0,
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
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                      thumbColor: Colors.blue,
                    ),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: _CourseVideoProgressSlider(
                        adapter: adapter,
                        duration: adapter.duration,
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
                      const SizedBox(width: 24.0),
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

class _CourseVideoProgressSlider extends StatefulWidget {
  final CourseVideoAdapter adapter;
  final Duration duration;

  const _CourseVideoProgressSlider({
    required this.adapter,
    required this.duration,
  });

  @override
  State<_CourseVideoProgressSlider> createState() =>
      _CourseVideoProgressSliderState();
}

class _CourseVideoProgressSliderState
    extends State<_CourseVideoProgressSlider> {
  Duration? _dragPosition;

  Duration _positionFor(double fraction) {
    return Duration(
      milliseconds: (fraction * widget.duration.inMilliseconds).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final durationMilliseconds = widget.duration.inMilliseconds;
    final pendingSeekPosition = widget.adapter.pendingSeekPosition;
    final position =
        _dragPosition ?? pendingSeekPosition ?? widget.adapter.position;
    final value = durationMilliseconds > 0
        ? (position.inMilliseconds / durationMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value, end: value),
      duration: _dragPosition == null
          ? const Duration(milliseconds: 180)
          : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        final sliderValue = _dragPosition != null || pendingSeekPosition != null
            ? value
            : animatedValue;
        return Slider(
          value: sliderValue.clamp(0.0, 1.0),
          onChangeStart: (fraction) {
            setState(() => _dragPosition = _positionFor(fraction));
          },
          onChanged: (fraction) {
            setState(() => _dragPosition = _positionFor(fraction));
          },
          onChangeEnd: (fraction) {
            final target = _positionFor(fraction);
            widget.adapter.seekTo(target);
            setState(() => _dragPosition = null);
          },
        );
      },
    );
  }
}

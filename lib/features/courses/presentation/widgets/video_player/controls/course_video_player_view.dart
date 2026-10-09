import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import '../adapters/course_video_adapter.dart';
import '../adapters/course_youtube_adapter.dart';
import '../adapters/course_webview_adapter.dart';

class CourseVideoPlayerView extends StatefulWidget {
  final CourseVideoAdapter adapter;
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;

  const CourseVideoPlayerView({
    super.key,
    required this.adapter,
    required this.isFullScreen,
    required this.onToggleFullScreen,
  });

  @override
  State<CourseVideoPlayerView> createState() => _CourseVideoPlayerViewState();
}

class _CourseVideoPlayerViewState extends State<CourseVideoPlayerView> {
  bool _showCustomControls =
      false; // By default hidden when playing, but we will sync it in _onAdapterStateChanged
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.adapter.addListener(_onAdapterStateChanged);
  }

  @override
  void didUpdateWidget(covariant CourseVideoPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adapter != widget.adapter) {
      oldWidget.adapter.removeListener(_onAdapterStateChanged);
      widget.adapter.addListener(_onAdapterStateChanged);
    }
  }

  @override
  void dispose() {
    widget.adapter.removeListener(_onAdapterStateChanged);
    super.dispose();
  }

  void _onAdapterStateChanged() {
    if (mounted) {
      setState(() {
        if (widget.adapter.isPlaying && !_wasPlaying) {
          // just started playing, hide it
          _showCustomControls = false;
        } else if (!widget.adapter.isPlaying && _wasPlaying) {
          // just paused, show it
          _showCustomControls = true;
        } else if (widget.adapter.position == Duration.zero &&
            !widget.adapter.isPlaying) {
          // initial state before playing
          _showCustomControls = true;
        }
        _wasPlaying = widget.adapter.isPlaying;
      });
    }
  }

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
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Full-screen tap detector for toggling UI (only for Vimeo and YouTube)
        // Must be the first child in Stack so that UI controls above it consume taps and prevent this from firing
        if (widget.adapter is CourseYoutubeAdapter ||
            (widget.adapter is CourseWebViewAdapter &&
                (widget.adapter as CourseWebViewAdapter).isVimeo))
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerUp: (_) {
                setState(() {
                  _showCustomControls = !_showCustomControls;
                });
              },
              child: const SizedBox.expand(),
            ),
          ),

        // 2. Buffering Indicator
        AnimatedBuilder(
          animation: widget.adapter,
          builder: (context, child) {
            if (widget.adapter.isBuffering && !widget.adapter.isPlaying) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // 3. Invisible touch blockers to prevent clicks on YouTube Title and Logo
        if (widget.adapter is CourseYoutubeAdapter)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100, // Blocks clicks on title and avatar
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // Consume tap but also toggle UI
                setState(() {
                  _showCustomControls = !_showCustomControls;
                });
              },
            ),
          ),
        if (widget.adapter is CourseYoutubeAdapter)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80, // Blocks clicks on logo and bottom elements
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // Consume tap but also toggle UI
                setState(() {
                  _showCustomControls = !_showCustomControls;
                });
              },
            ),
          ),

        // 4. Center Custom Play Button (ONLY for Vimeo, disabled for YouTube)
        if (widget.adapter is CourseWebViewAdapter &&
            (widget.adapter as CourseWebViewAdapter).isVimeo)
          Center(
            child: AnimatedBuilder(
              animation: widget.adapter,
              builder: (context, child) {
                if (!_showCustomControls) {
                  return const SizedBox.shrink();
                }
                return GestureDetector(
                  onTap: () {
                    if (widget.adapter.isPlaying) {
                      widget.adapter.pause();
                    } else {
                      widget.adapter.play();
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
                      widget.adapter.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 48.0,
                    ),
                  ),
                );
              },
            ),
          ),

        // 4. Bottom Controls UI
        if ((widget.adapter is CourseYoutubeAdapter ||
                (widget.adapter is CourseWebViewAdapter &&
                    (widget.adapter as CourseWebViewAdapter).isVimeo)) &&
            _showCustomControls)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: widget.adapter,
              builder: (context, child) {
                final replayButton = GestureDetector(
                  onTap: () {
                    widget.adapter.seekTo(
                      widget.adapter.position - const Duration(seconds: 10),
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
                    widget.adapter.seekTo(
                      widget.adapter.position + const Duration(seconds: 10),
                    );
                  },
                  child: const Icon(
                    Icons.forward_10,
                    color: Colors.white,
                    size: 24.0,
                  ),
                );

                final timeText =
                    widget.adapter.supportsPosition &&
                        widget.adapter.supportsDuration
                    ? AppText(
                        '${_formatDuration(widget.adapter.position)} / ${_formatDuration(widget.adapter.duration)}',
                        style: font12w400.copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      )
                    : const SizedBox.shrink();

                final volumeButton = widget.adapter.supportsVolume
                    ? GestureDetector(
                        onTap: () {
                          widget.adapter.toggleMute();
                        },
                        child: Icon(
                          widget.adapter.volume == 0
                              ? Icons.volume_off
                              : Icons.volume_up,
                          color: Colors.white,
                          size: 22.0,
                        ),
                      )
                    : const SizedBox.shrink();

                final fullscreenBtn = GestureDetector(
                  onTap: () {
                    widget.onToggleFullScreen();
                  },
                  child: Icon(
                    widget.isFullScreen
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen,
                    color: Colors.white,
                    size: 24.0,
                  ),
                );

                final playPauseButton = GestureDetector(
                  onTap: () {
                    if (widget.adapter.isPlaying) {
                      widget.adapter.pause();
                    } else {
                      widget.adapter.play();
                    }
                  },
                  child: Icon(
                    widget.adapter.isPlaying ? Icons.pause : Icons.play_arrow,
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
                      if (widget.adapter.supportsSeek) ...[
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
                              value:
                                  (widget.adapter.duration.inMilliseconds > 0)
                                  ? (widget.adapter.position.inMilliseconds /
                                            widget
                                                .adapter
                                                .duration
                                                .inMilliseconds)
                                        .clamp(0.0, 1.0)
                                  : 0.0,
                              onChanged: (value) {
                                final newPos = Duration(
                                  milliseconds:
                                      (value *
                                              widget
                                                  .adapter
                                                  .duration
                                                  .inMilliseconds)
                                          .toInt(),
                                );
                                widget.adapter.seekTo(newPos);
                              },
                            ),
                          ),
                        ),
                      ],
                      Row(
                        children: [
                          fullscreenBtn,
                          if (widget.adapter.supportsVolume) ...[
                            const SizedBox(width: 12.0),
                            volumeButton,
                          ],
                          const SizedBox(width: 12.0),
                          Expanded(child: timeText),
                          if (widget.adapter.supportsSeek) ...[
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
          ),

        // 5. Fullscreen Back Button
        if (widget.isFullScreen)
          Positioned(
            top: 24.0,
            right: 24.0,
            child: SafeArea(
              child: GestureDetector(
                onTap: widget.onToggleFullScreen,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

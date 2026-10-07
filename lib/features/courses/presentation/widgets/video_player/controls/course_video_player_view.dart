import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import '../adapters/course_video_adapter.dart';

class CourseVideoPlayerView extends StatefulWidget {
  final CourseVideoAdapter adapter;
  final Widget playerWidget;
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;

  const CourseVideoPlayerView({
    super.key,
    required this.adapter,
    required this.playerWidget,
    required this.isFullScreen,
    required this.onToggleFullScreen,
  });

  @override
  State<CourseVideoPlayerView> createState() => _CourseVideoPlayerViewState();
}

class _CourseVideoPlayerViewState extends State<CourseVideoPlayerView> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.adapter.addListener(_onAdapterStateChanged);
    _startHideTimer();
  }

  @override
  void didUpdateWidget(covariant CourseVideoPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adapter != widget.adapter) {
      oldWidget.adapter.removeListener(_onAdapterStateChanged);
      widget.adapter.addListener(_onAdapterStateChanged);
    }
  }

  void _onAdapterStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.adapter.removeListener(_onAdapterStateChanged);
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && widget.adapter.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "\${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AbsorbPointer(
              child: widget.playerWidget,
            ),
            Positioned.fill(
              child: Container(color: Colors.transparent),
            ),
            
            if (widget.adapter.isBuffering && !widget.adapter.isPlaying)
              const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),

            if (_showControls)
              Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          widget.adapter.togglePlayPause();
                          _startHideTimer();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.adapter.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 40.0,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4.0,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                              activeTrackColor: Colors.blue,
                              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                              thumbColor: Colors.blue,
                            ),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Slider(
                                value: (widget.adapter.duration.inMilliseconds > 0)
                                    ? (widget.adapter.position.inMilliseconds / widget.adapter.duration.inMilliseconds).clamp(0.0, 1.0)
                                    : 0.0,
                                onChanged: (value) {
                                  final newPos = Duration(milliseconds: (value * widget.adapter.duration.inMilliseconds).toInt());
                                  widget.adapter.seekTo(newPos);
                                  _startHideTimer();
                                },
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  widget.adapter.togglePlayPause();
                                  _startHideTimer();
                                },
                                child: Icon(
                                  widget.adapter.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              GestureDetector(
                                onTap: () {
                                  widget.adapter.seekTo(widget.adapter.position - const Duration(seconds: 10));
                                  _startHideTimer();
                                },
                                child: const Icon(Icons.replay_10, color: Colors.white, size: 24.0),
                              ),
                              const SizedBox(width: 8.0),
                              GestureDetector(
                                onTap: () {
                                  widget.adapter.seekTo(widget.adapter.position + const Duration(seconds: 10));
                                  _startHideTimer();
                                },
                                child: const Icon(Icons.forward_10, color: Colors.white, size: 24.0),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: AppText(
                                  '\${_formatDuration(widget.adapter.position)} / \${_formatDuration(widget.adapter.duration)}',
                                  style: font12w400.copyWith(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  widget.adapter.toggleMute();
                                  _startHideTimer();
                                },
                                child: Icon(
                                  widget.adapter.volume == 0 ? Icons.volume_off : Icons.volume_up,
                                  color: Colors.white,
                                  size: 22.0,
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              GestureDetector(
                                onTap: () {
                                  widget.onToggleFullScreen();
                                  _startHideTimer();
                                },
                                child: Icon(
                                  widget.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

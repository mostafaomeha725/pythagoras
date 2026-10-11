import 'package:flutter/material.dart';
import '../adapters/course_video_adapter.dart';
import '../adapters/course_youtube_adapter.dart';
import '../adapters/course_webview_adapter.dart';
import 'course_video_bottom_controls.dart';
import 'course_video_buffering_indicator.dart';
import 'course_video_fullscreen_back_button.dart';
import 'course_vimeo_center_play_button.dart';
import 'course_youtube_touch_blockers.dart';

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
  bool _showCustomControls = false;
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

  void _toggleCustomControls() {
    setState(() {
      _showCustomControls = !_showCustomControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isYoutube = widget.adapter is CourseYoutubeAdapter;
    final isVimeo = widget.adapter is CourseWebViewAdapter &&
        (widget.adapter as CourseWebViewAdapter).isVimeo;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Full-screen tap detector for toggling UI (only for Vimeo and YouTube)
        if (isYoutube || isVimeo)
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerUp: (_) => _toggleCustomControls(),
              child: const SizedBox.expand(),
            ),
          ),

        // 2. Buffering Indicator
        CourseVideoBufferingIndicator(adapter: widget.adapter),

        // 3. Invisible touch blockers to prevent clicks on YouTube Title and Logo
        if (isYoutube)
          CourseYoutubeTouchBlockers(onToggleControls: _toggleCustomControls),

        // 4. Center Custom Play Button (ONLY for Vimeo, disabled for YouTube)
        if (isVimeo)
          CourseVimeoCenterPlayButton(
            adapter: widget.adapter,
            showCustomControls: _showCustomControls,
          ),

        // 5. Bottom Controls UI
        if ((isYoutube || isVimeo) && _showCustomControls)
          CourseVideoBottomControls(
            adapter: widget.adapter,
            isFullScreen: widget.isFullScreen,
            onToggleFullScreen: widget.onToggleFullScreen,
          ),

        // 6. Fullscreen Back Button
        if (widget.isFullScreen)
          CourseVideoFullscreenBackButton(
            onToggleFullScreen: widget.onToggleFullScreen,
          ),
      ],
    );
  }
}

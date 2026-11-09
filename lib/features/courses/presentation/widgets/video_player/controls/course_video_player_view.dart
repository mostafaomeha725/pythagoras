import 'dart:async';

import 'package:flutter/material.dart';
import '../adapters/course_video_adapter.dart';
import '../adapters/course_youtube_adapter.dart';
import '../adapters/course_webview_adapter.dart';
import 'course_video_bottom_controls.dart';
import 'course_video_buffering_indicator.dart';
import 'course_video_center_control.dart';
import 'course_video_fullscreen_back_button.dart';
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
  static const _doubleTapTimeout = Duration(milliseconds: 400);
  static const _tapMovementTolerance = 24.0;

  bool _showCustomControls = false;
  bool _wasPlaying = false;
  Timer? _singleTapTimer;
  int? _activePointer;
  Offset? _pointerDownPosition;
  Duration? _pointerDownTime;
  Duration? _lastTapTime;
  bool? _lastTapWasRightSide;

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
    _singleTapTimer?.cancel();
    widget.adapter.removeListener(_onAdapterStateChanged);
    super.dispose();
  }

  void _onAdapterStateChanged() {
    if (!mounted) return;
    final isPlaying = widget.adapter.isPlaying;
    final isInitialPaused =
        widget.adapter.position == Duration.zero && !isPlaying;
    final stateChanged = isPlaying != _wasPlaying;
    if (!stateChanged && !(isInitialPaused && !_showCustomControls)) return;

    setState(() {
      if (isPlaying && !_wasPlaying) {
        _showCustomControls = false;
      } else if (!isPlaying && _wasPlaying) {
        _showCustomControls = true;
      } else if (isInitialPaused) {
        _showCustomControls = true;
      }
      _wasPlaying = isPlaying;
    });
  }

  void _toggleCustomControls() {
    setState(() {
      _showCustomControls = !_showCustomControls;
    });
  }

  void _handlePointerDown(PointerDownEvent event) {
    _activePointer = event.pointer;
    _pointerDownPosition = event.localPosition;
    _pointerDownTime = event.timeStamp;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_activePointer != event.pointer) return;

    final downPosition = _pointerDownPosition;
    final downTime = _pointerDownTime;
    _activePointer = null;
    _pointerDownPosition = null;
    _pointerDownTime = null;

    if (downPosition == null ||
        downTime == null ||
        (event.localPosition - downPosition).distance > _tapMovementTolerance ||
        event.timeStamp - downTime > _doubleTapTimeout) {
      return;
    }

    final width = context.size?.width ?? 0;
    if (width <= 0) return;
    final isRightSide = event.localPosition.dx >= width / 2;
    final previousTapTime = _lastTapTime;
    final isDoubleTap =
        previousTapTime != null &&
        event.timeStamp - previousTapTime <= _doubleTapTimeout &&
        _lastTapWasRightSide == isRightSide;

    if (isDoubleTap) {
      _singleTapTimer?.cancel();
      _singleTapTimer = null;
      _lastTapTime = null;
      _lastTapWasRightSide = null;
      widget.adapter.seekBy(
        isRightSide
            ? const Duration(seconds: 10)
            : const Duration(seconds: -10),
      );
      setState(() => _showCustomControls = true);
      return;
    }

    _singleTapTimer?.cancel();
    final controlsWereVisible = _showCustomControls;
    if (!controlsWereVisible) {
      setState(() => _showCustomControls = true);
    }

    _lastTapTime = event.timeStamp;
    _lastTapWasRightSide = isRightSide;
    _singleTapTimer = Timer(_doubleTapTimeout, () {
      _singleTapTimer = null;
      _lastTapTime = null;
      _lastTapWasRightSide = null;
      if (controlsWereVisible && mounted) {
        setState(() => _showCustomControls = false);
      }
    });
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (_activePointer != event.pointer) return;
    _activePointer = null;
    _pointerDownPosition = null;
    _pointerDownTime = null;
  }

  @override
  Widget build(BuildContext context) {
    final isYoutube = widget.adapter is CourseYoutubeAdapter;
    final isWebView = widget.adapter is CourseWebViewAdapter;
    final usesCustomControls = isYoutube || isWebView;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Invisible touch blockers to prevent clicks on YouTube Title and Logo
        if (isYoutube)
          CourseYoutubeTouchBlockers(onToggleControls: _toggleCustomControls),

        // 2. Route double-tap seeking through the adapter so the progress UI
        // updates immediately instead of waiting for YouTube's next time event.
        if (usesCustomControls)
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _handlePointerDown,
              onPointerUp: _handlePointerUp,
              onPointerCancel: _handlePointerCancel,
              child: const SizedBox.expand(),
            ),
          ),

        // 3. Shared center control keeps Vimeo and YouTube visually identical.
        if (usesCustomControls &&
            _showCustomControls &&
            !widget.adapter.isBuffering)
          CourseVideoCenterControl(adapter: widget.adapter, visible: true),

        // 4. Bottom Controls UI
        if (usesCustomControls && _showCustomControls)
          CourseVideoBottomControls(
            adapter: widget.adapter,
            isFullScreen: widget.isFullScreen,
            onToggleFullScreen: widget.onToggleFullScreen,
          ),

        // 5. Custom buffering state stays above all provider UI.
        CourseVideoBufferingIndicator(adapter: widget.adapter),

        // 6. Fullscreen Back Button
        if (widget.isFullScreen)
          CourseVideoFullscreenBackButton(
            onToggleFullScreen: widget.onToggleFullScreen,
          ),
      ],
    );
  }
}

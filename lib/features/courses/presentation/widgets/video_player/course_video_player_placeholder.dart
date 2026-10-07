import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_player_manager.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_fallback.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_youtube_player.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_native_video_player.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_webview_player.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/video_provider_type.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_error_overlay.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/controls/course_video_player_view.dart';

class CourseVideoPlayerPlaceholder extends StatefulWidget {
  final String imageUrl;
  final String? videoUrl;
  final String? videoType;

  const CourseVideoPlayerPlaceholder({
    super.key,
    required this.imageUrl,
    this.videoUrl,
    this.videoType,
  });

  @override
  State<CourseVideoPlayerPlaceholder> createState() =>
      _CourseVideoPlayerPlaceholderState();
}

class _CourseVideoPlayerPlaceholderState
    extends State<CourseVideoPlayerPlaceholder> {
  late final CourseVideoPlayerManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = CourseVideoPlayerManager();
    _manager.addListener(_onManagerStateChanged);
    _manager.initPlayer(widget.videoUrl, widget.videoType);
  }

  void _onManagerStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant CourseVideoPlayerPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl ||
        widget.videoType != oldWidget.videoType) {
      _manager.initPlayer(widget.videoUrl, widget.videoType);
    }
  }

  @override
  void dispose() {
    _manager.removeListener(_onManagerStateChanged);
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      return CourseVideoFallback(imageUrl: widget.imageUrl);
    }

    return PopScope(
      canPop: !_manager.isFullScreen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_manager.isFullScreen) {
          _manager.exitFullScreen();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: _manager.errorMessage != null
            ? Stack(
                children: [
                  CourseVideoFallback(imageUrl: widget.imageUrl),
                  Positioned.fill(
                    child: CourseVideoErrorOverlay(
                      errorMessage: _manager.errorMessage!,
                      onRetry: () => _manager.initPlayer(
                        widget.videoUrl,
                        widget.videoType,
                      ),
                    ),
                  ),
                ],
              )
            : _buildPlayer(),
      ),
    );
  }

  Widget _buildPlayer() {
    Widget? playerWidget;

    switch (_manager.providerType) {
      case VideoProviderType.youtube:
        if (_manager.ytController != null) {
          playerWidget = CourseYoutubePlayer(
            key: ValueKey(_manager.ytController.hashCode),
            controller: _manager.ytController!,
          );
        }
        break;
      case VideoProviderType.bunny:
        if (_manager.nativeController != null &&
            _manager.nativeController!.value.isInitialized) {
          playerWidget = CourseNativeVideoPlayer(
            key: ValueKey(_manager.nativeController.hashCode),
            controller: _manager.nativeController!,
          );
        }
        break;
      case VideoProviderType.vimeo:
      case VideoProviderType.viewlock:
      case VideoProviderType.unknown:
        if (_manager.webViewController != null) {
          playerWidget = CourseWebviewPlayer(
            key: ValueKey(_manager.webViewController.hashCode),
            controller: _manager.webViewController!,
          );
        }
        break;
    }

    if (playerWidget != null && _manager.adapter != null) {
      return CourseVideoPlayerView(
        key: ValueKey(widget.videoUrl), // Forces full rebuild on video change
        adapter: _manager.adapter!,
        playerWidget: playerWidget,
        isFullScreen: _manager.isFullScreen,
        onToggleFullScreen: () {
          _manager.toggleFullScreen();
        },
      );
    }

    // Loading state or fallback
    return CourseVideoFallback(imageUrl: widget.imageUrl);
  }
}

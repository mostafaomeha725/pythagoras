import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/utils/system_ui_manager.dart';

import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_player_manager.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_error_overlay.dart';
import 'course_video_content_view.dart';
import 'course_video_fullscreen_handler.dart';

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
    if (_manager.isFullScreen) {
      SystemUiManager.exitFullscreen();
    }
    _manager.removeListener(_onManagerStateChanged);
    _manager.dispose();
    super.dispose();
  }

  void _toggleFullscreen() {
    CourseVideoFullscreenHandler.toggleFullscreen(
      context: context,
      manager: _manager,
      videoUrl: widget.videoUrl,
      videoType: widget.videoType,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    final bool isWaitingForUrl =
        widget.videoUrl == null || widget.videoUrl!.isEmpty;
    final bool isFullscreenRoute =
        ModalRoute.of(context)?.settings.name == '/fullscreen_video';

    if (isWaitingForUrl) {
      content = Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    } else if (_manager.errorMessage != null) {
      content = Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          Positioned.fill(
            child: CourseVideoErrorOverlay(
              errorMessage: _manager.errorMessage!,
              onRetry: () =>
                  _manager.initPlayer(widget.videoUrl, widget.videoType),
            ),
          ),
        ],
      );
    } else {
      content = _buildPlayer();
    }

    content = ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: content,
    );

    if (!isFullscreenRoute) {
      return AspectRatio(aspectRatio: 16 / 9, child: content);
    }

    return content;
  }

  Widget _buildPlayer() {
    if (_manager.adapter == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_manager.isFullScreen) {
      // Return empty when in fullscreen to avoid duplicate GlobalKeys in widget tree
      return const SizedBox.shrink();
    }

    return CourseVideoContentView(
      manager: _manager,
      videoUrl: widget.videoUrl ?? '',
      isFullscreenRoute: false,
      onToggleFullScreen: _toggleFullscreen,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_player_manager.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_fallback.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_youtube_player.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_webview_player.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_error_overlay.dart';

class CourseVideoPlayerPlaceholder extends StatefulWidget {
  final String imageUrl;
  final String? videoUrl;
  
  const CourseVideoPlayerPlaceholder({
    super.key, 
    required this.imageUrl,
    this.videoUrl,
  });

  @override
  State<CourseVideoPlayerPlaceholder> createState() => _CourseVideoPlayerPlaceholderState();
}

class _CourseVideoPlayerPlaceholderState extends State<CourseVideoPlayerPlaceholder> {
  late final CourseVideoPlayerManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = CourseVideoPlayerManager();
    _manager.addListener(_onManagerStateChanged);
    _manager.initPlayer(widget.videoUrl);
  }

  void _onManagerStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant CourseVideoPlayerPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl) {
      _manager.initPlayer(widget.videoUrl);
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
                      onRetry: () => _manager.initPlayer(widget.videoUrl),
                    ),
                  ),
                ],
              )
            : _manager.youtubeId != null && _manager.ytController != null
                ? CourseYoutubePlayer(controller: _manager.ytController!)
                : _manager.webViewController != null
                    ? CourseWebviewPlayer(controller: _manager.webViewController!)
                    : CourseVideoFallback(imageUrl: widget.imageUrl),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/controls/course_video_player_view.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_native_video_player.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_player_manager.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_webview_player.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_youtube_player.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/video_provider_type.dart';

class CourseVideoContentView extends StatelessWidget {
  final CourseVideoPlayerManager manager;
  final String videoUrl;
  final bool isFullscreenRoute;
  final VoidCallback onToggleFullScreen;

  const CourseVideoContentView({
    super.key,
    required this.manager,
    required this.videoUrl,
    this.isFullscreenRoute = false,
    required this.onToggleFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    if (manager.adapter == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final customControls = CourseVideoPlayerView(
      key: ValueKey('${videoUrl}_$isFullscreenRoute'),
      adapter: manager.adapter!,
      isFullScreen: manager.isFullScreen,
      onToggleFullScreen: onToggleFullScreen,
    );

    Widget? player;

    switch (manager.providerType) {
      case VideoProviderType.youtube:
        if (manager.ytController != null) {
          player = CourseYoutubePlayer(
            key: manager.playerKey,
            controller: manager.ytController!,
            customControls: customControls,
          );
        }
        break;
      case VideoProviderType.native:
        if (manager.nativeController != null) {
          player = CourseNativeVideoPlayer(
            key: manager.playerKey,
            controller: manager.nativeController!,
            customControls: customControls,
          );
        }
        break;
      case VideoProviderType.bunny:
      case VideoProviderType.vimeo:
      case VideoProviderType.viewlock:
      case VideoProviderType.unknown:
        if (manager.webViewController != null) {
          player = CourseWebviewPlayer(
            key: manager.playerKey,
            controller: manager.webViewController!,
            customControls: customControls,
          );
        }
        break;
    }

    if (player == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: player),
        if (manager.isInitializing)
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

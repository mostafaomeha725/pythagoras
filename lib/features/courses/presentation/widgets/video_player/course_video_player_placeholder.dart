import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/utils/system_ui_manager.dart';

import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_player_manager.dart';

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
    if (_manager.isFullScreen) {
      SystemUiManager.exitFullscreen();
    }
    _manager.removeListener(_onManagerStateChanged);
    _manager.dispose();
    super.dispose();
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

    return _buildPlayerWidget();
  }

  void _triggerExitFullscreen() {
    // 1. Rotate device back to Portrait WHILE STILL in the unrestricted Fullscreen Route.
    // This prevents the Portrait Route's Column from overflowing during the orientation change.
    SystemUiManager.exitFullscreen().then((_) {
      // 2. Wait for the engine to complete the layout in Portrait mode.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // 3. Now that the screen is safely Portrait, relinquish the GlobalKey and pop.
        if (_manager.isFullScreen) {
          _manager.exitFullScreen();
        }
        Navigator.of(context, rootNavigator: true).pop();
      });
    });
  }

  Future<void> _handleFullscreenToggle() async {
    if (!_manager.isFullScreen) {
      // 1. Sync state change + route push FIRST.
      // This safely extracts the GlobalKey from the restrictive Portrait Route
      // (which has Columns that can overflow) into the unrestricted Fullscreen Route.
      _manager.toggleFullScreen();

      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          opaque:
              false, // Keeps the underlying route in the render tree to prevent Surface detachment
          fullscreenDialog: true,
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          pageBuilder: (context, animation, secondaryAnimation) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                _triggerExitFullscreen();
              },
              child: Scaffold(
                backgroundColor: Colors.black,
                body: AnimatedBuilder(
                  animation: _manager,
                  builder: (context, child) {
                    return Center(
                      child: _manager.isFullScreen
                          ? _buildPlayerWidget(isFullscreenRoute: true)
                          : const SizedBox.shrink(),
                    );
                  },
                ),
              ),
            );
          },
        ),
      );

      // 2. Wait ONE frame to guarantee the RenderTree has fully reparented the PlatformView.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          // 3. NOW rotate the device. The Fullscreen Route will smoothly resize without overflowing!
          await SystemUiManager.enterFullscreen();
        }
      });
    } else {
      // Exiting fullscreen programmatically (via UI button)
      _triggerExitFullscreen();
    }
  }

  Widget _buildPlayerWidget({bool isFullscreenRoute = false}) {
    final customControls = CourseVideoPlayerView(
      key: ValueKey('${widget.videoUrl}_$isFullscreenRoute'),
      adapter: _manager.adapter!,
      isFullScreen: _manager.isFullScreen,
      onToggleFullScreen: _handleFullscreenToggle,
    );

    Widget? player;

    switch (_manager.providerType) {
      case VideoProviderType.youtube:
        if (_manager.ytController != null) {
          player = CourseYoutubePlayer(
            key: _manager.playerKey,
            controller: _manager.ytController!,
            customControls: customControls,
          );
        }
        break;
      case VideoProviderType.native:
        if (_manager.nativeController != null) {
          player = CourseNativeVideoPlayer(
            key: _manager.playerKey,
            controller: _manager.nativeController!,
            customControls: customControls,
          );
        }
        break;
      case VideoProviderType.bunny:
      case VideoProviderType.vimeo:
      case VideoProviderType.viewlock:
      case VideoProviderType.unknown:
        if (_manager.webViewController != null) {
          player = CourseWebviewPlayer(
            key: _manager.playerKey,
            controller: _manager.webViewController!,
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
        Container(color: Colors.black),
        if (_manager.isInitializing)
          Positioned(
            left: 0,
            top: 0,
            width: 1,
            height: 1,
            child: player,
          )
        else
          Positioned.fill(child: player),
        if (_manager.isInitializing)
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
      ],
    );
  }
}

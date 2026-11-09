import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/core/utils/system_ui_manager.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_error_overlay.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_player_manager.dart';
import 'course_video_content_view.dart';

class CourseVideoFullscreenHandler {
  CourseVideoFullscreenHandler._();

  static void exitFullscreen({
    required BuildContext context,
    required CourseVideoPlayerManager manager,
  }) {
    if (manager.isExitingFullScreen) return;
    manager.isExitingFullScreen = true;

    final bool wasPlaying = manager.adapter?.isPlaying ?? false;
    final bool isTablet = manager.wasTablet;
    final Orientation? targetOrientation = manager.preFullscreenOrientation;

    // 1. Set orientation and system UI mode while still in the unrestricted Fullscreen Route.
    // On tablet landscape, this preserves landscape and does NOT force portrait.
    // On tablet portrait, this returns to portrait.
    // On mobile, this preserves existing mobile behavior.
    SystemUiManager.exitFullscreen(
      isTablet: isTablet,
      targetOrientation: targetOrientation,
    ).then((_) {
      // 2. Wait for the engine to complete layout.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          manager.isExitingFullScreen = false;
          return;
        }
        // 3. Relinquish the GlobalKey and pop the fullscreen route.
        if (manager.isFullScreen) {
          manager.exitFullScreen();
        }
        Navigator.of(context, rootNavigator: true).pop();

        if (isTablet) {
          // Unlock orientations on tablet so the user can freely rotate via sensor
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SystemUiManager.unlockOrientations();
          });
        }

        bool isIOS = !kIsWeb && Platform.isIOS;
        if (isIOS && wasPlaying) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) manager.adapter?.play();
          });
        }
      });
    });
  }

  static Future<void> toggleFullscreen({
    required BuildContext context,
    required CourseVideoPlayerManager manager,
    required String? videoUrl,
    required String? videoType,
  }) async {
    if (!manager.isFullScreen) {
      final bool wasPlaying = manager.adapter?.isPlaying ?? false;
      final bool isIOS = !kIsWeb && Platform.isIOS;
      final bool needsPlaybackWorkaround = wasPlaying && isIOS;
      if (needsPlaybackWorkaround) {
        manager.adapter?.pause();
      }

      // Record device type and pre-fullscreen orientation before pushing route
      manager.wasTablet = ResponsiveHelper.isTablet(context);
      manager.preFullscreenOrientation = MediaQuery.orientationOf(context);
      manager.isExitingFullScreen = false;

      // 1. Sync state change + route push FIRST.
      // This safely extracts the GlobalKey from the restrictive Portrait Route
      // (which has Columns that can overflow) into the unrestricted Fullscreen Route.
      manager.toggleFullScreen();

      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          opaque:
              false, // Keeps the underlying route in the render tree to prevent Surface detachment
          fullscreenDialog: true,
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 180),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final easedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(opacity: easedAnimation, child: child);
          },
          pageBuilder: (context, animation, secondaryAnimation) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                exitFullscreen(context: context, manager: manager);
              },
              child: Scaffold(
                backgroundColor: Colors.black,
                body: AnimatedBuilder(
                  animation: manager,
                  builder: (context, child) {
                    if (!manager.isFullScreen) {
                      return const SizedBox.shrink();
                    }
                    if (manager.errorMessage != null) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: Colors.black),
                          Positioned.fill(
                            child: CourseVideoErrorOverlay(
                              errorMessage: manager.errorMessage!,
                              onRetry: () =>
                                  manager.initPlayer(videoUrl, videoType),
                            ),
                          ),
                        ],
                      );
                    }
                    return Center(
                      child: CourseVideoContentView(
                        manager: manager,
                        videoUrl: videoUrl ?? '',
                        isFullscreenRoute: true,
                        onToggleFullScreen: () =>
                            exitFullscreen(context: context, manager: manager),
                      ),
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
        if (context.mounted) {
          // 3. NOW rotate the device. The Fullscreen Route will smoothly resize without overflowing!
          await SystemUiManager.enterFullscreen();

          if (needsPlaybackWorkaround) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (context.mounted) manager.adapter?.play();
            });
          }
        }
      });
    } else {
      // Exiting fullscreen programmatically (via UI button)
      exitFullscreen(context: context, manager: manager);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Manages the state and logic for the video player (Youtube & Webview).
/// Extracted from the UI widget to enforce Clean Architecture.
class CourseVideoPlayerManager extends ChangeNotifier {
  YoutubePlayerController? ytController;
  WebViewController? webViewController;
  String? youtubeId;
  bool isFullScreen = false;
  String? errorMessage;

  void initPlayer(String? videoUrl) {
    errorMessage = null;
    if (videoUrl == null || videoUrl.isEmpty) {
      _disposePlayers();
      return;
    }

    final newYoutubeId = YoutubePlayerController.convertUrlToId(videoUrl);

    if (newYoutubeId != null) {
      youtubeId = newYoutubeId;
      // It's a YouTube video
      _disposeWebViewController();

      if (ytController != null) {
        // Reuse existing controller for instant loading!
        ytController!.loadVideoById(videoId: youtubeId!);
      } else {
        // Create new controller
        ytController = YoutubePlayerController.fromVideoId(
          videoId: youtubeId!,
          autoPlay: false,
          params: const YoutubePlayerParams(
            showFullscreenButton: true,
            mute: false,
            showControls: true,
            strictRelatedVideos: true,
          ),
        );

        ytController!.listen((value) {
          bool needsNotify = false;
          
          if (value.error != YoutubeError.none) {
            final newError = 'عذراً، حدثت مشكلة في تحميل هذا الفيديو. (السبب: ${value.error.name})';
            if (errorMessage != newError) {
              errorMessage = newError;
              needsNotify = true;
            }
          } else if (errorMessage != null) {
            errorMessage = null;
            needsNotify = true;
          }

          if (value.fullScreenOption.enabled != isFullScreen) {
            final bool wasPlaying = value.playerState == PlayerState.playing;
            isFullScreen = value.fullScreenOption.enabled;
            
            if (isFullScreen) {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);
            } else {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);
            }
            
            // Fix: Android WebView sometimes pauses the video when changing orientations/parents.
            if (wasPlaying) {
              Future.delayed(const Duration(milliseconds: 400), () {
                ytController?.playVideo();
              });
            }
            needsNotify = true;
          }

          if (needsNotify) notifyListeners();
        });
      }
    } else {
      // It's Vimeo, Bunny, Viewlock, or other embed URL
      youtubeId = null;
      _disposeYoutubeController();

      if (webViewController != null) {
        webViewController!.loadRequest(Uri.parse(videoUrl));
      } else {
        webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.black)
          ..setNavigationDelegate(
            NavigationDelegate(
              onWebResourceError: (WebResourceError error) {
                errorMessage = 'فشل تحميل الفيديو. يرجى التحقق من اتصالك بالإنترنت.';
                notifyListeners();
              },
            ),
          )
          ..loadRequest(Uri.parse(videoUrl));
      }
    }

    notifyListeners();
  }

  void _disposePlayers() {
    _disposeYoutubeController();
    _disposeWebViewController();
    notifyListeners();
  }

  void _disposeYoutubeController() {
    ytController?.close();
    ytController = null;
  }

  void _disposeWebViewController() {
    webViewController = null;
  }

  void exitFullScreen() {
    ytController?.exitFullScreen();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _disposeYoutubeController();
    _disposeWebViewController();
    super.dispose();
  }
}

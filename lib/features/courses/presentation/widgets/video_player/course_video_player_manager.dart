import 'package:flutter/material.dart';

import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:screen_protector/screen_protector.dart';

import 'package:pythagoras/features/courses/presentation/widgets/video_player/video_provider_type.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/adapters/course_video_adapter.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/adapters/course_youtube_adapter.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/adapters/course_native_adapter.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/adapters/course_webview_adapter.dart';

/// Manages the state and logic for the unified video player.
class CourseVideoPlayerManager extends ChangeNotifier {
  VideoProviderType providerType = VideoProviderType.unknown;

  // Controllers
  CourseVideoAdapter? adapter;
  YoutubePlayerController? ytController;
  VideoPlayerController? nativeController;
  WebViewController? webViewController;

  // GlobalKey to maintain player state across route changes (Fullscreen)
  final GlobalKey playerKey = GlobalKey();

  bool isFullScreen = false;
  String? errorMessage;
  String? currentVideoUrl;

  void initPlayer(String? videoUrl, [String? videoTypeStr]) async {
    if (videoUrl == currentVideoUrl && errorMessage == null) {
      return; // Already initialized
    }

    currentVideoUrl = videoUrl;
    errorMessage = null;

    if (videoUrl == null || videoUrl.isEmpty) {
      _disposePlayers();
      return;
    }

    // Enable Screen Protection
    await ScreenProtector.protectDataLeakageOn();
    await ScreenProtector.preventScreenshotOn();

    final newProviderType = determineVideoProvider(videoUrl, videoTypeStr);
    final actualNewProviderType = _isDirectVideo(videoUrl) ? VideoProviderType.bunny : newProviderType;

    // Reuse existing YouTube controller if switching between YouTube videos
    if (providerType == VideoProviderType.youtube &&
        actualNewProviderType == VideoProviderType.youtube &&
        ytController != null) {
      final youtubeId = YoutubePlayerController.convertUrlToId(videoUrl) ?? videoUrl;
      ytController!.loadVideoById(videoId: youtubeId);
      currentVideoUrl = videoUrl;
      notifyListeners();
      return;
    }

    providerType = actualNewProviderType;

    _disposePlayers(keepScreenProtection: true); // Clear previous controllers

    try {
      switch (providerType) {
        case VideoProviderType.youtube:
          _initYoutube(videoUrl);
          break;
        case VideoProviderType.bunny:
          _initNative(videoUrl);
          break;
        case VideoProviderType.vimeo:
        case VideoProviderType.viewlock:
        case VideoProviderType.unknown:
          final embedUrl = formatEmbedUrl(videoUrl, providerType);
          _initWebView(embedUrl);
          break;
      }
    } catch (e) {
      errorMessage = 'عذراً، حدثت مشكلة في تهيئة الفيديو.';
    }

    notifyListeners();
  }

  void _initYoutube(String url) {
    final youtubeId = YoutubePlayerController.convertUrlToId(url) ?? url;
    ytController = YoutubePlayerController.fromVideoId(
      videoId: youtubeId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: false,
        mute: false,
        showControls: false,
        strictRelatedVideos: true,
        pointerEvents: PointerEvents.initial,
      ),
    );
    adapter = CourseYoutubeAdapter(ytController!);

    ytController!.listen((value) {
      bool needsNotify = false;

      if (value.error != YoutubeError.none) {
        final newError =
            'عذراً، حدثت مشكلة في تحميل هذا الفيديو. (السبب: ${value.error.name})';
        if (errorMessage != newError) {
          errorMessage = newError;
          needsNotify = true;
        }
      }

      if (needsNotify) notifyListeners();
    });
  }

  void _initNative(String url) {
    nativeController = VideoPlayerController.networkUrl(Uri.parse(url));
    nativeController!
        .initialize()
        .then((_) {
          notifyListeners();
        })
        .catchError((e) {
          errorMessage = 'عذراً، تعذر تشغيل الفيديو.';
          notifyListeners();
        });
    nativeController!.addListener(() {
      if (nativeController!.value.hasError) {
        errorMessage = 'عذراً، حدث خطأ أثناء تشغيل الفيديو.';
        notifyListeners();
      }
    });
    adapter = CourseNativeAdapter(nativeController!);
  }

  void _initWebView(String url) {
    debugPrint('Init WebView with URL: $url');

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    if (webViewController!.platform is AndroidWebViewController) {
      (webViewController!.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    webViewController!
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('WebView NavigationRequest: ${request.url}');

            // Allow standard web navigation for the player to work (redirects, iframes, CDNs)
            // Block only completely unhandled schemes to prevent crashes
            if (request.url.startsWith('intent://') ||
                request.url.startsWith('mailto:') ||
                request.url.startsWith('tel:')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
              'WebView Error: URL: $url | ErrorCode: ${error.errorCode} | Description: ${error.description}',
            );
            // Don't show error for standard tracking/ad blockers failing
            if (error.errorCode != -2 && error.description.isNotEmpty) {
              errorMessage =
                  'WebView Error: ${error.errorCode} - ${error.description}';
              notifyListeners();
            }
          },
          onPageStarted: (String pageUrl) {
            debugPrint('WebView PageStarted: $pageUrl');
          },
          onPageFinished: (String pageUrl) {
            debugPrint('WebView PageFinished: $pageUrl');
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    adapter = CourseWebViewAdapter(webViewController!);
  }

  bool _isDirectVideo(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.m3u8') ||
        lower.contains('.mp4?') ||
        lower.contains('.m3u8?');
  }

  void _toggleFullScreen(bool fullScreen) {
    isFullScreen = fullScreen;
  }

  void exitFullScreen() {
    _toggleFullScreen(false);
    notifyListeners();
  }

  void toggleFullScreen() {
    _toggleFullScreen(!isFullScreen);
    notifyListeners();
  }

  void _disposePlayers({bool keepScreenProtection = false}) {
    adapter?.disposeAdapter();
    adapter = null;

    ytController?.close();
    ytController = null;

    nativeController?.dispose();
    nativeController = null;

    webViewController = null;

    if (!keepScreenProtection) {
      ScreenProtector.protectDataLeakageOff();
      ScreenProtector.preventScreenshotOff();
    }
  }

  @override
  void dispose() {
    _disposePlayers();
    super.dispose();
  }
}

import 'dart:async';
import 'dart:io';
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
  bool _isDisposed = false;

  // Controllers
  CourseVideoAdapter? adapter;
  YoutubePlayerController? ytController;
  VideoPlayerController? nativeController;
  WebViewController? webViewController;

  // Key to maintain player state across route changes (Fullscreen)
  // We refresh this key when switching videos to ensure a clean UI state.
  GlobalKey playerKey = GlobalKey();

  bool isFullScreen = false;
  bool isInitializing = false;
  String? errorMessage;
  String? currentVideoUrl;
  Timer? _networkTimer;

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  Future<void> _handleError(String fallbackMsg, String url) async {
    if (_isDisposed || currentVideoUrl != url) return;

    final hasInternet = await _hasInternetConnection();
    if (_isDisposed || currentVideoUrl != url) return;

    if (!hasInternet) {
      errorMessage = 'لا يوجد اتصال بالإنترنت، تأكد من اتصالك وحاول مرة أخرى.';
    } else {
      errorMessage = fallbackMsg;
    }
    isInitializing = false;
    _disposePlayers(keepScreenProtection: true);
    notifyListeners();
  }

  void _startTimeoutTimer(String url) {
    _networkTimer?.cancel();
    _networkTimer = Timer(const Duration(seconds: 15), () async {
      // Allow timeout if it's still initializing OR if it's stuck buffering
      final isStuck = isInitializing || (adapter?.isBuffering ?? true);
      if (currentVideoUrl != url || _isDisposed || !isStuck) return;

      final hasInternet = await _hasInternetConnection();
      if (currentVideoUrl != url ||
          _isDisposed ||
          (!isInitializing && !(adapter?.isBuffering ?? true))) {
        return;
      }

      isInitializing = false;
      if (!hasInternet) {
        errorMessage =
            'لا يوجد اتصال بالإنترنت، تأكد من اتصالك وحاول مرة أخرى.';
      } else {
        errorMessage =
            'استغرق تحميل الفيديو وقتاً طويلاً. يرجى إعادة المحاولة.';
      }
      _disposePlayers(keepScreenProtection: true);
      notifyListeners();
    });
  }

  void _startImmediateNetworkCheck(String url) async {
    final hasInternet = await _hasInternetConnection();
    final isStuck = isInitializing || (adapter?.isBuffering ?? true);
    if (_isDisposed || currentVideoUrl != url || !isStuck) return;

    if (!hasInternet) {
      _networkTimer?.cancel();
      isInitializing = false;
      errorMessage = 'لا يوجد اتصال بالإنترنت، تأكد من اتصالك وحاول مرة أخرى.';
      _disposePlayers(keepScreenProtection: true);
      notifyListeners();
    }
  }

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

    // 1. Force Loading immediately to avoid Empty Image before async tasks
    currentVideoUrl = videoUrl;
    isInitializing = true;
    notifyListeners();

    // Start immediate network check (takes max 3s)
    _startImmediateNetworkCheck(videoUrl);

    // Start robust timeout monitoring (15s)
    _startTimeoutTimer(videoUrl);

    // Enable Screen Protection safely without crashing
    try {
      await ScreenProtector.protectDataLeakageOn();
      await ScreenProtector.preventScreenshotOn();
    } catch (e) {
      debugPrint('ScreenProtector init failed: $e');
    }

    // 2. Race condition check: abort if user selected another video while awaiting
    if (currentVideoUrl != videoUrl) return;

    final newProviderType = determineVideoProvider(videoUrl, videoTypeStr);
    final actualNewProviderType = _isDirectVideo(videoUrl)
        ? VideoProviderType.native
        : newProviderType;

    // We no longer reuse the YouTube controller. Reusing it causes the old
    // video's last frame to remain visible because state listeners leak the old state.

    providerType = actualNewProviderType;

    _disposePlayers(keepScreenProtection: true); // Clear previous controllers

    try {
      isInitializing = true;
      switch (providerType) {
        case VideoProviderType.youtube:
          _initYoutube(videoUrl);
          break;
        case VideoProviderType.native:
          _initNative(videoUrl);
          break;
        case VideoProviderType.bunny:
          _initWebView(videoUrl, isVimeo: false);
          break;
        case VideoProviderType.vimeo:
          final embedUrl = formatEmbedUrl(videoUrl, providerType);
          _initWebView(embedUrl, isVimeo: true);
          break;
        case VideoProviderType.viewlock:
        case VideoProviderType.unknown:
          final embedUrl = formatEmbedUrl(videoUrl, providerType);
          _initWebView(embedUrl, isVimeo: false);
          break;
      }
    } catch (e) {
      _handleError('عذراً، حدثت مشكلة في تهيئة الفيديو.', videoUrl);
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
        showVideoAnnotations: false,
        strictRelatedVideos: true,
        pointerEvents: PointerEvents.initial,
        enableKeyboard: false,
      ),
    );
    adapter = CourseYoutubeAdapter(ytController!);
    notifyListeners();

    ytController!.listen((value) {
      bool needsNotify = false;

      if (value.error != YoutubeError.none && errorMessage == null) {
        _handleError(
          'عذراً، حدثت مشكلة في تحميل هذا الفيديو. (السبب: ${value.error.name})',
          url,
        );
      }

      if (isInitializing &&
          (value.playerState == PlayerState.playing ||
              value.playerState == PlayerState.paused)) {
        isInitializing = false;
        needsNotify = true;
      }

      if (needsNotify) notifyListeners();
    });
  }

  void _initNative(String url) {
    nativeController = VideoPlayerController.networkUrl(Uri.parse(url));
    final controller = nativeController!;

    controller
        .initialize()
        .then((_) {
          if (nativeController != controller) return;
          isInitializing = false;
          notifyListeners();
        })
        .catchError((e) {
          if (nativeController != controller) return;
          _handleError('عذراً، تعذر تشغيل الفيديو.', url);
        });
    controller.addListener(() {
      if (nativeController != controller) return;
      if (controller.value.hasError && errorMessage == null) {
        _handleError(
          'عذراً، انقطع الاتصال أو حدث خطأ أثناء تشغيل الفيديو.',
          url,
        );
      }
    });
    adapter = CourseNativeAdapter(controller);
    notifyListeners();
  }

  void _initWebView(String url, {bool isVimeo = false}) {
    debugPrint('Init WebView with URL: $url (isVimeo: $isVimeo)');

    webViewController = WebViewController()
      ..setBackgroundColor(Colors.black)
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    final controller = webViewController!;

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    adapter = CourseWebViewAdapter(controller, isVimeo: isVimeo);
    notifyListeners();

    controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          debugPrint('WebView NavigationRequest: \${request.url}');

          if (request.url.startsWith('intent://') ||
              request.url.startsWith('mailto:') ||
              request.url.startsWith('tel:')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageFinished: (String url) {
          if (webViewController != controller) return;
          // For non-Vimeo webviews (like Bunny stream links), we hide loader on page finish.
          // For Vimeo, we wait for the JS 'ready' message to hide the loader.
          if (!isVimeo && isInitializing) {
            isInitializing = false;
            notifyListeners();
          }
        },
        onWebResourceError: (WebResourceError error) {
          if (webViewController != controller) return;
          debugPrint(
            'WebView Error: URL: $url | ErrorCode: ${error.errorCode} | Description: ${error.description}',
          );
          // Only show fatal errors that affect the main frame to prevent
          // blocking the video just because a background tracker failed to load.
          if (error.isForMainFrame == true && errorMessage == null) {
            _handleError(
              'عذراً، حدثت مشكلة أثناء تحميل الفيديو. يرجى المحاولة مرة أخرى.',
              url,
            );
          }
        },
      ),
    );

    if (isVimeo) {
      final videoId = _extractVimeoId(url);
      final html =
          '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0">
          <style>body, html { margin: 0; padding: 0; width: 100%; height: 100%; background: black; overflow: hidden; }</style>
        </head>
        <body>
          <iframe id="vimeo-player" src="https://player.vimeo.com/video/$videoId?controls=0&autoplay=1&playsinline=1" width="100%" height="100%" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>
          <script src="https://player.vimeo.com/api/player.js"></script>
          <script>
            var iframe = document.querySelector('iframe');
            var player = new Vimeo.Player(iframe);
            
            player.on('timeupdate', function(data) {
               window.VimeoFlutterChannel.postMessage(JSON.stringify({
                  event: 'timeupdate',
                  duration: data.duration,
                  currentTime: data.seconds
               }));
            });
            player.on('play', function() {
               window.VimeoFlutterChannel.postMessage(JSON.stringify({ event: 'play' }));
            });
            player.on('pause', function() {
               window.VimeoFlutterChannel.postMessage(JSON.stringify({ event: 'pause' }));
            });
            
            window.flutterPlay = function() { player.play(); };
            window.flutterPause = function() { player.pause(); };
            window.flutterSeek = function(sec) { player.setCurrentTime(sec); };
            window.flutterVolume = function(vol) { player.setVolume(vol); };
            
            player.getDuration().then(function(dur) {
                window.VimeoFlutterChannel.postMessage(JSON.stringify({
                  event: 'ready',
                  duration: dur
               }));
            }).catch(function() {});
          </script>
        </body>
        </html>
      ''';
      controller.addJavaScriptChannel(
        'VimeoFlutterChannel',
        onMessageReceived: (msg) {
          if (webViewController != controller) return;

          if (isInitializing) {
            isInitializing = false;
            notifyListeners();
          }

          if (adapter is CourseWebViewAdapter) {
            (adapter as CourseWebViewAdapter).handleVimeoMessage(msg.message);
          }
        },
      );
      controller.loadHtmlString(html);
    } else {
      controller.loadRequest(Uri.parse(url));
    }
  }

  String _extractVimeoId(String url) {
    final regex = RegExp(r'vimeo\.com/(?:video/)?(\d+)');
    final match = regex.firstMatch(url);
    if (match != null) {
      return match.group(1) ?? url;
    }
    // fallback
    return url;
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
    playerKey = GlobalKey(); // Force widget tree to drop the old player state

    adapter?.disposeAdapter();
    adapter = null;

    try {
      ytController?.close();
    } catch (e) {
      debugPrint('YoutubePlayer close exception: $e');
    }
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
    _isDisposed = true;
    _networkTimer?.cancel();
    _disposePlayers();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }
}

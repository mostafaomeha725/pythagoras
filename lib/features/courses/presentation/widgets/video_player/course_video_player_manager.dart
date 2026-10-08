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

  void _initWebView(String url, {bool isVimeo = false}) {
    debugPrint('Init WebView with URL: $url (isVimeo: $isVimeo)');

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    if (webViewController!.platform is AndroidWebViewController) {
      (webViewController!.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    adapter = CourseWebViewAdapter(webViewController!, isVimeo: isVimeo);

    webViewController!.setNavigationDelegate(
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
        onWebResourceError: (WebResourceError error) {
          debugPrint(
            'WebView Error: URL: $url | ErrorCode: \${error.errorCode} | Description: \${error.description}',
          );
          if (error.errorCode != -2 && error.description.isNotEmpty) {
            errorMessage =
                'WebView Error: \${error.errorCode} - \${error.description}';
            notifyListeners();
          }
        },
      ),
    );

    if (isVimeo) {
      final videoId = _extractVimeoId(url);
      final html = '''
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
      webViewController!.addJavaScriptChannel('VimeoFlutterChannel', onMessageReceived: (msg) {
        if (adapter is CourseWebViewAdapter) {
          (adapter as CourseWebViewAdapter).handleVimeoMessage(msg.message);
        }
      });
      webViewController!.loadHtmlString(html);
    } else {
      webViewController!.loadRequest(Uri.parse(url));
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

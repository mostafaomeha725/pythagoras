import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'package:pythagoras/features/courses/presentation/widgets/video_player/video_provider_type.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/adapters/course_video_adapter.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/adapters/course_youtube_adapter.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/adapters/course_native_adapter.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/adapters/course_webview_adapter.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/utils/course_video_screen_security.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/utils/course_video_network_checker.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/utils/course_video_url_helper.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/utils/course_vimeo_embed_builder.dart';

/// Manages the state and logic for the unified video player.
class CourseVideoPlayerManager extends ChangeNotifier {
  CourseVideoPlayerManager({
    Future<bool> Function()? hasInternetConnection,
    Future<void> Function()? enableScreenProtection,
    Future<void> Function()? disableScreenProtection,
    YoutubePlayerController Function(String, YoutubePlayerParams)?
    youtubeControllerFactory,
  }) : _hasInternetConnection =
           hasInternetConnection ??
           CourseVideoNetworkChecker.hasInternetConnection,
       _enableScreenProtection =
           enableScreenProtection ?? CourseVideoScreenSecurity.enable,
       _disableScreenProtection =
           disableScreenProtection ?? CourseVideoScreenSecurity.disable,
       _youtubeControllerFactory =
           youtubeControllerFactory ?? _createYoutubeController;

  static YoutubePlayerController _createYoutubeController(
    String videoId,
    YoutubePlayerParams params,
  ) {
    return YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: params,
    );
  }

  final Future<bool> Function() _hasInternetConnection;
  final Future<void> Function() _enableScreenProtection;
  final Future<void> Function() _disableScreenProtection;
  final YoutubePlayerController Function(String, YoutubePlayerParams)
  _youtubeControllerFactory;

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
  StreamSubscription<YoutubePlayerValue>? _youtubeValueSubscription;
  int _initializationGeneration = 0;
  int _youtubeControllerCreationCount = 0;
  bool _nativeRecoveryInProgress = false;
  Duration? _nativeResumePosition;
  bool _nativeResumePlayback = false;

  // Fullscreen orientation state tracking (Tablet support)
  bool wasTablet = false;
  Orientation? preFullscreenOrientation;
  bool isExitingFullScreen = false;

  bool _isCurrentSession(String url, int generation) {
    return !_isDisposed &&
        currentVideoUrl == url &&
        _initializationGeneration == generation;
  }

  void _debugYoutubeLog(String message) {
    if (kDebugMode) developer.log(message, name: 'CourseYoutubePlayer');
  }

  Future<void> _handleError(
    String fallbackMsg,
    String url,
    int generation,
  ) async {
    if (!_isCurrentSession(url, generation)) return;

    final hasInternet = await _hasInternetConnection();
    if (!_isCurrentSession(url, generation)) return;

    if (!hasInternet) {
      errorMessage = 'لا يوجد اتصال بالإنترنت، تأكد من اتصالك وحاول مرة أخرى.';
    } else {
      errorMessage = fallbackMsg;
    }
    isInitializing = false;
    _networkTimer?.cancel();
    notifyListeners();
    await _disposePlayers(keepScreenProtection: true);
  }

  void _startTimeoutTimer(String url, int generation) {
    _networkTimer?.cancel();
    _networkTimer = Timer(const Duration(seconds: 15), () async {
      // Allow timeout if it's still initializing OR if it's stuck buffering
      final isStuck = isInitializing || (adapter?.isBuffering ?? true);
      if (!_isCurrentSession(url, generation) || !isStuck) return;

      final hasInternet = await _hasInternetConnection();
      if (!_isCurrentSession(url, generation) ||
          (!isInitializing && !(adapter?.isBuffering ?? true))) {
        return;
      }

      isInitializing = false;
      if (!hasInternet) {
        errorMessage = 'لا يوجد اتصال بالإنترنت، تأكد من اتصالك';
      } else {
        errorMessage =
            'استغرق تحميل الفيديو وقتاً طويلاً. يرجى إعادة المحاولة.';
      }
      notifyListeners();
      await _disposePlayers(keepScreenProtection: true);
    });
  }

  Future<void> _startImmediateNetworkCheck(String url, int generation) async {
    final hasInternet = await _hasInternetConnection();
    final isStuck = isInitializing || (adapter?.isBuffering ?? true);
    if (!_isCurrentSession(url, generation) || !isStuck) return;

    if (!hasInternet) {
      _networkTimer?.cancel();
      isInitializing = false;
      errorMessage = 'لا يوجد اتصال بالإنترنت، تأكد من اتصالك وحاول مرة أخرى.';
      notifyListeners();
      await _disposePlayers(keepScreenProtection: true);
    }
  }

  Future<void> initPlayer(String? videoUrl, [String? videoTypeStr]) async {
    if (videoUrl == currentVideoUrl && errorMessage == null) {
      return; // Already initialized
    }

    final generation = ++_initializationGeneration;
    _nativeRecoveryInProgress = false;
    _nativeResumePosition = null;
    _nativeResumePlayback = false;
    currentVideoUrl = videoUrl;
    errorMessage = null;
    _networkTimer?.cancel();

    if (videoUrl == null || videoUrl.isEmpty) {
      isInitializing = false;
      await _disposePlayers();
      notifyListeners();
      return;
    }

    isInitializing = true;
    notifyListeners();

    await _disposePlayers(keepScreenProtection: true);
    if (!_isCurrentSession(videoUrl, generation) || errorMessage != null) {
      return;
    }

    unawaited(_startImmediateNetworkCheck(videoUrl, generation));
    _startTimeoutTimer(videoUrl, generation);

    await _enableScreenProtection();
    if (!_isCurrentSession(videoUrl, generation) || errorMessage != null) {
      return;
    }

    final newProviderType = determineVideoProvider(videoUrl, videoTypeStr);
    final actualNewProviderType = CourseVideoUrlHelper.isDirectVideo(videoUrl)
        ? VideoProviderType.native
        : newProviderType;

    providerType = actualNewProviderType;

    try {
      isInitializing = true;
      switch (providerType) {
        case VideoProviderType.youtube:
          _initYoutube(videoUrl, generation);
          break;
        case VideoProviderType.native:
          _initNative(videoUrl, generation);
          break;
        case VideoProviderType.bunny:
          _initWebView(videoUrl, generation, isVimeo: false);
          break;
        case VideoProviderType.vimeo:
          final embedUrl = formatEmbedUrl(videoUrl, providerType);
          _initWebView(embedUrl, generation, isVimeo: true);
          break;
        case VideoProviderType.viewlock:
        case VideoProviderType.unknown:
          final embedUrl = formatEmbedUrl(videoUrl, providerType);
          _initWebView(embedUrl, generation, isVimeo: false);
          break;
      }
    } catch (e) {
      await _handleError(
        'عذراً، حدثت مشكلة في تهيئة الفيديو.',
        videoUrl,
        generation,
      );
    }

    notifyListeners();
  }

  void _initYoutube(String url, int generation) {
    final youtubeId = YoutubePlayerController.convertUrlToId(url) ?? url;
    final controller = _youtubeControllerFactory(
      youtubeId,
      const YoutubePlayerParams(
        showFullscreenButton: false,
        mute: false,
        enableCaption: false,
        showControls: false,
        showVideoAnnotations: false,
        strictRelatedVideos: true,
        pointerEvents: PointerEvents.none,
        enableKeyboard: false,
        videoStateUpdateInterval: 250,
      ),
    );
    ytController = controller;
    _youtubeControllerCreationCount++;
    _debugYoutubeLog(
      'controllerCreated count=$_youtubeControllerCreationCount '
      'state=${controller.value.playerState.name} positionMs=0 durationMs=0 buffering=false',
    );
    adapter = CourseYoutubeAdapter(controller);
    notifyListeners();

    _youtubeValueSubscription = controller.listen((value) {
      if (!_isCurrentSession(url, generation) || ytController != controller) {
        return;
      }

      final currentAdapter = adapter;
      _debugYoutubeLog(
        'state=${value.playerState.name} errorCode=${value.error.code} '
        'positionMs=${currentAdapter?.position.inMilliseconds ?? 0} '
        'durationMs=${currentAdapter?.duration.inMilliseconds ?? 0} '
        'buffering=${currentAdapter?.isBuffering ?? false}',
      );

      if (value.error != YoutubeError.none && errorMessage == null) {
        unawaited(_handleYoutubeError(value.error, url, generation));
        return;
      }

      if (isInitializing &&
          (value.playerState == PlayerState.playing ||
              value.playerState == PlayerState.paused)) {
        _networkTimer?.cancel();
        isInitializing = false;
        notifyListeners();
      }
    });
  }

  Future<void> _handleYoutubeError(
    YoutubeError error,
    String url,
    int generation,
  ) async {
    if (!_isCurrentSession(url, generation) || errorMessage != null) return;

    _debugYoutubeLog('fatalError code=${error.code} error=${error.name}');
    final hasInternet = await _hasInternetConnection();
    if (!_isCurrentSession(url, generation)) return;

    errorMessage = !hasInternet
        ? 'لا يوجد اتصال بالإنترنت، تأكد من اتصالك وحاول مرة أخرى.'
        : switch (error) {
            YoutubeError.invalidParam => 'رابط فيديو YouTube غير صالح (رمز 2).',
            YoutubeError.html5Error => 'واجه مشغل YouTube خطأ HTML5 (رمز 5).',
            YoutubeError.videoNotFound || YoutubeError.cannotFindVideo =>
              'فيديو YouTube غير موجود أو خاص (رمز ${error.code}).',
            YoutubeError.notEmbeddable ||
            YoutubeError.sameAsNotEmbeddable ||
            YoutubeError.sameAsNotEmbeddable2 =>
              'مالك الفيديو لا يسمح بتشغيله داخل التطبيق (رمز ${error.code}).',
            YoutubeError.none => 'حدث خطأ غير متوقع في مشغل YouTube.',
            YoutubeError.unknown =>
              'أبلغ YouTube عن خطأ غير معروف. تعذر على إصدار المشغل الحالي تحديد رمزه.',
          };
    isInitializing = false;
    _networkTimer?.cancel();
    notifyListeners();
    await _disposePlayers(keepScreenProtection: true);
  }

  void _initNative(String url, int generation) {
    nativeController = VideoPlayerController.networkUrl(Uri.parse(url));
    final controller = nativeController!;

    controller
        .initialize()
        .then((_) async {
          if (nativeController != controller) return;

          final resumePosition = _nativeResumePosition;
          final resumePlayback = _nativeResumePlayback;
          _nativeResumePosition = null;
          _nativeResumePlayback = false;

          if (resumePosition != null && resumePosition > Duration.zero) {
            await controller.seekTo(resumePosition);
            if (resumePlayback) await controller.play();
          }

          _nativeRecoveryInProgress = false;
          isInitializing = false;
          notifyListeners();
        })
        .catchError((e) {
          if (nativeController != controller) return;
          unawaited(
            _handleError('عذراً، تعذر تشغيل الفيديو.', url, generation),
          );
        });
    controller.addListener(() {
      if (nativeController != controller) return;
      if (controller.value.hasError && errorMessage == null) {
        if (_nativeRecoveryInProgress) {
          _handleError(
            'عذراً، انقطع الاتصال أو حدث خطأ أثناء تشغيل الفيديو.',
            url,
            generation,
          );
        } else {
          unawaited(_recoverNativePlayback(url, generation, controller));
        }
      }
    });
    adapter = CourseNativeAdapter(controller);
    notifyListeners();
  }

  Future<void> _recoverNativePlayback(
    String url,
    int generation,
    VideoPlayerController failedController,
  ) async {
    if (_nativeRecoveryInProgress || !_isCurrentSession(url, generation)) {
      return;
    }

    _nativeRecoveryInProgress = true;
    _nativeResumePosition = failedController.value.position;
    _nativeResumePlayback = failedController.value.isPlaying;
    isInitializing = true;
    _networkTimer?.cancel();
    notifyListeners();

    await _disposePlayers(keepScreenProtection: true);
    if (!_isCurrentSession(url, generation)) {
      _nativeRecoveryInProgress = false;
      _nativeResumePosition = null;
      _nativeResumePlayback = false;
      return;
    }

    _startTimeoutTimer(url, generation);
    _initNative(url, generation);
  }

  void _initWebView(String url, int generation, {bool isVimeo = false}) {
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
          debugPrint('WebView NavigationRequest: ${request.url}');

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
              generation,
            );
          }
        },
      ),
    );

    if (isVimeo) {
      final videoId = CourseVimeoEmbedBuilder.extractVimeoId(url);
      final html = CourseVimeoEmbedBuilder.buildHtml(videoId);
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

  void _toggleFullScreen(bool fullScreen) {
    isFullScreen = fullScreen;
  }

  void exitFullScreen() {
    isExitingFullScreen = false;
    _toggleFullScreen(false);
    notifyListeners();
  }

  void toggleFullScreen() {
    _toggleFullScreen(!isFullScreen);
    notifyListeners();
  }

  Future<void> _disposePlayers({bool keepScreenProtection = false}) async {
    isExitingFullScreen = false;
    playerKey = GlobalKey(); // Force widget tree to drop the old player state

    adapter?.disposeAdapter();
    adapter = null;

    final youtubeSubscription = _youtubeValueSubscription;
    _youtubeValueSubscription = null;
    await youtubeSubscription?.cancel();

    final youtubeController = ytController;
    ytController = null;
    if (youtubeController != null) {
      try {
        await youtubeController.close();
      } catch (e) {
        debugPrint('YoutubePlayer close exception: $e');
      }
    }

    final previousNativeController = nativeController;
    nativeController = null;
    await previousNativeController?.dispose();

    webViewController = null;

    if (!keepScreenProtection) {
      await _disableScreenProtection();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _initializationGeneration++;
    _networkTimer?.cancel();
    unawaited(_disposePlayers());
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }
}

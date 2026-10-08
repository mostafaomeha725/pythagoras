import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'course_video_adapter.dart';

class CourseWebViewAdapter extends CourseVideoAdapter {
  final WebViewController controller;
  Timer? _timer;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  bool _isMuted = false;

  @override
  bool get supportsVolume => false;

  CourseWebViewAdapter(this.controller) {
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _syncState(),
    );
  }

  Future<void> _syncState() async {
    try {
      final jsResult = await controller.runJavaScriptReturningResult('''
        (function() {
          var style = document.getElementById('custom-hide-style');
          if (!style) {
            style = document.createElement('style');
            style.id = 'custom-hide-style';
            // Only hide the big central play button for Plyr (used by Bunny).
            // Avoiding general selectors to not affect other providers.
            style.innerHTML = `
              .plyr__control--overlaid { 
                display: none !important; 
                opacity: 0 !important; 
                visibility: hidden !important; 
                z-index: -9999 !important; 
                pointer-events: none !important;
              }
            `;
            document.head.appendChild(style);
          }
          var v = document.querySelector('video');
          if (!v) return null;
          return JSON.stringify({
            paused: v.paused,
            currentTime: v.currentTime,
            duration: v.duration,
            volume: v.volume,
            muted: v.muted
          });
        })();
      ''');

      if (jsResult != null && jsResult != 'null') {
        String resultStr = jsResult.toString();
        if (resultStr.startsWith("'") || resultStr.startsWith('"')) {
          resultStr = resultStr.substring(1, resultStr.length - 1);
        }

        // primitive JSON parsing to avoid heavy imports
        bool paused = resultStr.contains('"paused":true');
        double currentTime = _extractDouble(resultStr, '"currentTime":');
        double duration = _extractDouble(resultStr, '"duration":');
        double volume = _extractDouble(resultStr, '"volume":');
        bool muted = resultStr.contains('"muted":true');

        _isPlaying = !paused;
        if (!duration.isNaN && duration > 0) {
          _duration = Duration(milliseconds: (duration * 1000).toInt());
        }
        _position = Duration(milliseconds: (currentTime * 1000).toInt());
        _volume = volume;
        _isMuted = muted;

        notifyListeners();
      }
    } catch (_) {}
  }

  double _extractDouble(String json, String key) {
    int startIndex = json.indexOf(key);
    if (startIndex == -1) return 0.0;
    startIndex += key.length;
    int endIndex = json.indexOf(',', startIndex);
    if (endIndex == -1) {
      endIndex = json.indexOf('}', startIndex);
    }
    String valStr = json.substring(startIndex, endIndex);
    return double.tryParse(valStr) ?? 0.0;
  }

  @override
  bool get isPlaying => _isPlaying;

  @override
  bool get isBuffering => false; // Hard to detect generically

  @override
  Duration get position => _position;

  @override
  Duration get duration => _duration;

  @override
  double get volume => _isMuted ? 0.0 : _volume;

  @override
  void play() {
    controller.runJavaScript("document.querySelector('video')?.play();");
    _isPlaying = true;
    notifyListeners();
  }

  @override
  void pause() {
    controller.runJavaScript("document.querySelector('video')?.pause();");
    _isPlaying = false;
    notifyListeners();
  }

  @override
  void togglePlayPause() {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }

  @override
  void seekTo(Duration pos) {
    final seconds = pos.inMilliseconds / 1000.0;
    controller.runJavaScript(
      "document.querySelector('video').currentTime = $seconds;",
    );
    _position = pos;
    notifyListeners();
  }

  @override
  void setVolume(double vol) {
    controller.runJavaScript("document.querySelector('video').volume = $vol;");
  }

  @override
  void toggleMute() {
    final newMuted = !_isMuted;
    controller.runJavaScript(
      "document.querySelector('video').muted = $newMuted;",
    );
    _isMuted = newMuted;
    notifyListeners();
  }

  @override
  void disposeAdapter() {
    _timer?.cancel();
  }
}

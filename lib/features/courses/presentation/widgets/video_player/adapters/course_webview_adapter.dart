import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'course_video_adapter.dart';

class CourseWebViewAdapter extends CourseVideoAdapter {
  final WebViewController controller;
  final bool isVimeo;
  Timer? _timer;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  bool _isMuted = false;

  @override
  bool get supportsVolume => false;

  CourseWebViewAdapter(this.controller, {this.isVimeo = false}) {
    if (!isVimeo) {
      _timer = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) => _syncState(),
      );
    }
  }

  void handleVimeoMessage(String message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      final event = data['event'];
      
      debugPrint('[VIMEO] JS Event: $event, Data: $data');

      if (event == 'ready') {
        final dur = (data['duration'] as num?)?.toDouble() ?? 0.0;
        if (dur > 0) _duration = Duration(milliseconds: (dur * 1000).toInt());
        debugPrint('[VIMEO] duration = ${_duration.inSeconds}s');
      } else if (event == 'timeupdate') {
        final dur = (data['duration'] as num?)?.toDouble() ?? 0.0;
        final curr = (data['currentTime'] as num?)?.toDouble() ?? 0.0;
        if (dur > 0) _duration = Duration(milliseconds: (dur * 1000).toInt());
        if (curr >= 0) _position = Duration(milliseconds: (curr * 1000).toInt());
        debugPrint('[VIMEO] currentTime = ${_position.inSeconds}s');
      } else if (event == 'play') {
        _isPlaying = true;
        debugPrint('[VIMEO] play');
      } else if (event == 'pause') {
        _isPlaying = false;
        debugPrint('[VIMEO] pause');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[VIMEO] message parse error: $e');
    }
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
          var videos = document.getElementsByTagName('video');
          var v = null;
          var maxDur = 0;
          for (var i = 0; i < videos.length; i++) {
            if (videos[i].duration && !isNaN(videos[i].duration) && videos[i].duration > maxDur) {
              maxDur = videos[i].duration;
              v = videos[i];
            }
          }
          if (!v && videos.length > 0) v = videos[0];
          
          if (!v) {
            return JSON.stringify({ error: 'No video element found' });
          }
          
          return JSON.stringify({
            paused: v.paused,
            currentTime: v.currentTime,
            duration: v.duration,
            volume: v.volume,
            muted: v.muted,
            vimeo_videos_count: videos.length
          });
        })();
      ''');

      debugPrint('[VIMEO] RAW JS RESULT: $jsResult');

      if (jsResult.toString() != 'null') {
        String resultStr = jsResult.toString();

        // runJavaScriptReturningResult returns a JSON-encoded string for string results.
        if (resultStr.startsWith('"') || resultStr.startsWith("'")) {
          try {
            resultStr = jsonDecode(resultStr);
          } catch (_) {
            resultStr = resultStr
                .substring(1, resultStr.length - 1)
                .replaceAll(r'\"', '"');
          }
        }

        try {
          final Map<String, dynamic> data = jsonDecode(resultStr);
          debugPrint('[VIMEO] PARSED JSON DATA: $data');

          if (data.containsKey('error')) {
            debugPrint('[VIMEO] JS ERROR: ${data['error']}');
            return;
          }

          bool paused = data['paused'] == true;
          double currentTime = (data['currentTime'] as num?)?.toDouble() ?? 0.0;
          double duration = (data['duration'] as num?)?.toDouble() ?? 0.0;
          double volume = (data['volume'] as num?)?.toDouble() ?? 1.0;
          bool muted = data['muted'] == true;

          debugPrint(
            '[VIMEO] EXTRACTED -> duration: $duration, currentTime: $currentTime, paused: $paused',
          );

          _isPlaying = !paused;
          if (duration > 0 && !duration.isNaN) {
            _duration = Duration(milliseconds: (duration * 1000).toInt());
          }
          if (currentTime >= 0 && !currentTime.isNaN) {
            _position = Duration(milliseconds: (currentTime * 1000).toInt());
          }
          _volume = volume;
          _isMuted = muted;

          debugPrint(
            '[VIMEO] ADAPTER UPDATED -> duration: ${_duration.inSeconds}s, position: ${_position.inSeconds}s',
          );

          notifyListeners();
        } catch (e) {
          debugPrint('[VIMEO] JSON DECODE ERROR: $e');
        }
      }
    } catch (_) {}
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
    if (isVimeo) {
      controller.runJavaScript("if(window.flutterPlay) window.flutterPlay();");
    } else {
      controller.runJavaScript("document.querySelector('video')?.play();");
    }
    _isPlaying = true;
    notifyListeners();
  }

  @override
  void pause() {
    if (isVimeo) {
      controller.runJavaScript("if(window.flutterPause) window.flutterPause();");
    } else {
      controller.runJavaScript("document.querySelector('video')?.pause();");
    }
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
    if (isVimeo) {
      controller.runJavaScript("if(window.flutterSeek) window.flutterSeek($seconds);");
      debugPrint('[VIMEO] seeked to $seconds');
    } else {
      controller.runJavaScript(
        "var v = document.querySelector('video'); if (v) v.currentTime = $seconds;",
      );
    }
    _position = pos;
    notifyListeners();
  }

  @override
  void setVolume(double vol) {
    if (isVimeo) {
      controller.runJavaScript("if(window.flutterVolume) window.flutterVolume($vol);");
    } else {
      controller.runJavaScript("var v = document.querySelector('video'); if (v) v.volume = $vol;");
    }
  }

  @override
  void toggleMute() {
    final newMuted = !_isMuted;
    if (isVimeo) {
      controller.runJavaScript("if(window.flutterVolume) window.flutterVolume(${newMuted ? 0.0 : 1.0});");
    } else {
      controller.runJavaScript(
        "var v = document.querySelector('video'); if (v) v.muted = $newMuted;",
      );
    }
    _isMuted = newMuted;
    notifyListeners();
  }

  @override
  void disposeAdapter() {
    _timer?.cancel();
    _timer = null;
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'course_video_adapter.dart';
import 'course_vimeo_message_parser.dart';
import 'course_webview_scripts.dart';
import 'course_webview_state_parser.dart';

class CourseWebViewAdapter extends CourseVideoAdapter {
  final WebViewController controller;
  final bool isVimeo;
  Timer? _timer;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  bool _isMuted = false;
  bool hasError = false;
  int _errorConsecutiveCount = 0;

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
    final eventData = CourseVimeoMessageParser.parse(message);
    if (eventData == null) return;

    if (eventData.duration != null) {
      _duration = eventData.duration!;
    }
    if (eventData.position != null) {
      _position = eventData.position!;
    }
    if (eventData.isPlaying != null) {
      _isPlaying = eventData.isPlaying!;
    }
    notifyListeners();
  }

  Future<void> _syncState() async {
    try {
      final jsResult = await controller.runJavaScriptReturningResult(
        CourseWebViewScripts.videoStateSyncScript,
      );

      final state = CourseWebViewStateParser.parse(jsResult);
      if (state == null) return;

      if (state.hasError) {
        _errorConsecutiveCount++;
        if (_errorConsecutiveCount >= 4 && !hasError) {
          hasError = true;
          notifyListeners();
        }
        return;
      }

      _errorConsecutiveCount = 0;
      if (hasError) {
        hasError = false;
        notifyListeners();
      }

      _isPlaying = state.isPlaying;
      if (state.duration != null) {
        _duration = state.duration!;
      }
      if (state.position != null) {
        _position = state.position!;
      }
      _volume = state.volume;
      _isMuted = state.isMuted;

      debugPrint(
        '[WEBVIEW] ADAPTER UPDATED -> duration: ${_duration.inSeconds}s, position: ${_position.inSeconds}s',
      );

      notifyListeners();
    } catch (_) {}
  }

  @override
  bool get isPlaying => _isPlaying;

  @override
  bool get isBuffering => false;

  @override
  Duration get position => _position;

  @override
  Duration get duration => _duration;

  @override
  double get volume => _isMuted ? 0.0 : _volume;

  @override
  double get playbackSpeed => _playbackSpeed;

  @override
  void play() {
    controller.runJavaScript(CourseWebViewScripts.playScript(isVimeo: isVimeo));
    _isPlaying = true;
    notifyListeners();
  }

  @override
  void pause() {
    controller.runJavaScript(
      CourseWebViewScripts.pauseScript(isVimeo: isVimeo),
    );
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
      CourseWebViewScripts.seekScript(seconds, isVimeo: isVimeo),
    );
    if (isVimeo) {
      debugPrint('[VIMEO] seeked to $seconds');
    }
    _position = pos;
    notifyListeners();
  }

  @override
  void setVolume(double vol) {
    controller.runJavaScript(
      CourseWebViewScripts.setVolumeScript(vol, isVimeo: isVimeo),
    );
  }

  @override
  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    controller.runJavaScript(
      CourseWebViewScripts.setPlaybackSpeedScript(speed, isVimeo: isVimeo),
    );
    notifyListeners();
  }

  @override
  void toggleMute() {
    final newMuted = !_isMuted;
    controller.runJavaScript(
      CourseWebViewScripts.toggleMuteScript(newMuted, isVimeo: isVimeo),
    );
    _isMuted = newMuted;
    notifyListeners();
  }

  @override
  void disposeAdapter() {
    _timer?.cancel();
    _timer = null;
  }
}

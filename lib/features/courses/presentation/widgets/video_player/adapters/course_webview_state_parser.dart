import 'dart:convert';
import 'package:flutter/foundation.dart';

class CourseWebViewVideoState {
  final bool hasError;
  final String? errorMessage;
  final bool isPlaying;
  final Duration? duration;
  final Duration? position;
  final double volume;
  final bool isMuted;

  const CourseWebViewVideoState({
    this.hasError = false,
    this.errorMessage,
    this.isPlaying = false,
    this.duration,
    this.position,
    this.volume = 1.0,
    this.isMuted = false,
  });
}

class CourseWebViewStateParser {
  CourseWebViewStateParser._();

  static CourseWebViewVideoState? parse(dynamic jsResult) {
    if (jsResult == null || jsResult.toString() == 'null') {
      return null;
    }

    debugPrint('[WEBVIEW] RAW JS RESULT: $jsResult');

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
      debugPrint('[WEBVIEW] PARSED JSON DATA: $data');

      if (data.containsKey('error')) {
        final errorMsg = data['error']?.toString();
        debugPrint('[WEBVIEW] JS ERROR: $errorMsg');
        return CourseWebViewVideoState(hasError: true, errorMessage: errorMsg);
      }

      final paused = data['paused'] == true;
      final currentTime = (data['currentTime'] as num?)?.toDouble() ?? 0.0;
      final durationSeconds = (data['duration'] as num?)?.toDouble() ?? 0.0;
      final volume = (data['volume'] as num?)?.toDouble() ?? 1.0;
      final muted = data['muted'] == true;

      debugPrint(
        '[WEBVIEW] EXTRACTED -> duration: $durationSeconds, currentTime: $currentTime, paused: $paused',
      );

      Duration? duration;
      if (durationSeconds > 0 && !durationSeconds.isNaN) {
        duration = Duration(milliseconds: (durationSeconds * 1000).toInt());
      }

      Duration? position;
      if (currentTime >= 0 && !currentTime.isNaN) {
        position = Duration(milliseconds: (currentTime * 1000).toInt());
      }

      return CourseWebViewVideoState(
        hasError: false,
        isPlaying: !paused,
        duration: duration,
        position: position,
        volume: volume,
        isMuted: muted,
      );
    } catch (e) {
      debugPrint('[WEBVIEW] JSON DECODE ERROR: $e');
      return null;
    }
  }
}

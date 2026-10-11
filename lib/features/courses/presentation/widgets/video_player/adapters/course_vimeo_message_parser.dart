import 'dart:convert';
import 'package:flutter/foundation.dart';

class CourseVimeoEventData {
  final String? event;
  final Duration? duration;
  final Duration? position;
  final bool? isPlaying;

  const CourseVimeoEventData({
    this.event,
    this.duration,
    this.position,
    this.isPlaying,
  });
}

class CourseVimeoMessageParser {
  CourseVimeoMessageParser._();

  static CourseVimeoEventData? parse(String message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      final event = data['event'];

      debugPrint('[VIMEO] JS Event: $event, Data: $data');

      Duration? duration;
      Duration? position;
      bool? isPlaying;

      if (event == 'ready') {
        final dur = (data['duration'] as num?)?.toDouble() ?? 0.0;
        if (dur > 0) duration = Duration(milliseconds: (dur * 1000).toInt());
        if (duration != null) {
          debugPrint('[VIMEO] duration = ${duration.inSeconds}s');
        }
      } else if (event == 'timeupdate') {
        final dur = (data['duration'] as num?)?.toDouble() ?? 0.0;
        final curr = (data['currentTime'] as num?)?.toDouble() ?? 0.0;
        if (dur > 0) duration = Duration(milliseconds: (dur * 1000).toInt());
        if (curr >= 0) position = Duration(milliseconds: (curr * 1000).toInt());
        if (position != null) {
          debugPrint('[VIMEO] currentTime = ${position.inSeconds}s');
        }
      } else if (event == 'play') {
        isPlaying = true;
        debugPrint('[VIMEO] play');
      } else if (event == 'pause') {
        isPlaying = false;
        debugPrint('[VIMEO] pause');
      }

      return CourseVimeoEventData(
        event: event?.toString(),
        duration: duration,
        position: position,
        isPlaying: isPlaying,
      );
    } catch (e) {
      debugPrint('[VIMEO] message parse error: $e');
      return null;
    }
  }
}

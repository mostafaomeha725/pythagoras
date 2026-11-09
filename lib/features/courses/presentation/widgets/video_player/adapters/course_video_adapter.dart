import 'package:flutter/material.dart';

abstract class CourseVideoAdapter extends ChangeNotifier {
  bool get isPlaying;
  bool get isBuffering;
  Duration get position;
  Duration? get pendingSeekPosition => null;
  Duration get duration;
  double get volume;
  bool get isMuted => volume == 0;
  double get playbackSpeed;

  // Capabilities
  bool get supportsPlayPause => true;
  bool get supportsSeek => true;
  bool get supportsVolume => true;
  bool get supportsPosition => true;
  bool get supportsDuration => true;
  bool get supportsCustomControls => true;

  void play();
  void pause();
  void togglePlayPause();
  void seekTo(Duration position);
  void seekBy(Duration offset) {
    final target = position + offset;
    final maxPosition = duration;
    seekTo(
      target < Duration.zero
          ? Duration.zero
          : maxPosition > Duration.zero && target > maxPosition
          ? maxPosition
          : target,
    );
  }

  void setVolume(double volume);
  void setPlaybackSpeed(double speed);
  void toggleMute();
  void disposeAdapter();
}

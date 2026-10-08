import 'package:flutter/material.dart';

abstract class CourseVideoAdapter extends ChangeNotifier {
  bool get isPlaying;
  bool get isBuffering;
  Duration get position;
  Duration get duration;
  double get volume;

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
  void setVolume(double volume);
  void toggleMute();
  void disposeAdapter();
}

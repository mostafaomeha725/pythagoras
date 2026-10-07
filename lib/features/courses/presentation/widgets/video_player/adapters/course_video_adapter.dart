import 'package:flutter/material.dart';

abstract class CourseVideoAdapter extends ChangeNotifier {
  bool get isPlaying;
  bool get isBuffering;
  Duration get position;
  Duration get duration;
  double get volume;

  void play();
  void pause();
  void togglePlayPause();
  void seekTo(Duration position);
  void setVolume(double volume);
  void toggleMute();
  void disposeAdapter();
}

import 'package:video_player/video_player.dart';
import 'course_video_adapter.dart';

class CourseNativeAdapter extends CourseVideoAdapter {
  final VideoPlayerController controller;
  double _playbackSpeed = 1.0;

  CourseNativeAdapter(this.controller) {
    controller.addListener(notifyListeners);
  }

  @override
  bool get isPlaying => controller.value.isPlaying;

  @override
  bool get isBuffering => controller.value.isBuffering;

  @override
  Duration get position => controller.value.position;

  @override
  Duration get duration => controller.value.duration;

  @override
  double get volume => controller.value.volume;

  @override
  double get playbackSpeed => _playbackSpeed;

  @override
  void play() => controller.play();

  @override
  void pause() => controller.pause();

  @override
  void togglePlayPause() {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }

  @override
  void seekTo(Duration pos) => controller.seekTo(pos);

  @override
  void setVolume(double vol) => controller.setVolume(vol);

  @override
  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    controller.setPlaybackSpeed(speed);
    notifyListeners();
  }

  @override
  void toggleMute() {
    if (volume == 0) {
      setVolume(1.0);
    } else {
      setVolume(0.0);
    }
  }

  @override
  void disposeAdapter() {
    controller.removeListener(notifyListeners);
  }
}

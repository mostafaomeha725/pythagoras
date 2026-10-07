import 'dart:async';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'course_video_adapter.dart';

class CourseYoutubeAdapter extends CourseVideoAdapter {
  final YoutubePlayerController controller;
  Timer? _timer;
  
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  bool _isMuted = false;

  CourseYoutubeAdapter(this.controller) {
    controller.listen((event) {
      notifyListeners();
    });
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) => _syncState());
  }

  Future<void> _syncState() async {
    try {
      final pos = await controller.currentTime;
      final vol = await controller.volume;
      final muted = await controller.isMuted;
      
      _position = Duration(milliseconds: (pos * 1000).toInt());
      _volume = muted ? 0.0 : (vol / 100);
      _isMuted = muted;
      
      notifyListeners();
    } catch (_) {}
  }

  @override
  bool get isPlaying => controller.value.playerState == PlayerState.playing;

  @override
  bool get isBuffering => controller.value.playerState == PlayerState.buffering;

  @override
  Duration get position => _position;

  @override
  Duration get duration {
    if (controller.value.metaData.duration.inMilliseconds > 0) {
      _duration = controller.value.metaData.duration;
    }
    return _duration;
  }

  @override
  double get volume => _volume;

  @override
  void play() => controller.playVideo();

  @override
  void pause() => controller.pauseVideo();

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
    controller.seekTo(seconds: pos.inMilliseconds / 1000.0, allowSeekAhead: true);
  }

  @override
  void setVolume(double vol) {
    controller.setVolume(vol >= 1.0 ? 100 : (vol * 100).toInt());
    if (vol > 0 && _isMuted) {
      controller.unMute();
    }
  }

  @override
  void toggleMute() {
    if (_isMuted || _volume == 0) {
      controller.unMute();
    } else {
      controller.mute();
    }
  }

  @override
  void disposeAdapter() {
    _timer?.cancel();
    // we don't dispose the controller here as manager owns it
  }
}

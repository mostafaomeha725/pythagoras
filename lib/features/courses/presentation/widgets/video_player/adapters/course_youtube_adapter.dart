import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'course_video_adapter.dart';

class CourseYoutubeAdapter extends CourseVideoAdapter {
  final YoutubePlayerController controller;
  static const Duration _seekDebounceDuration = Duration(milliseconds: 100);

  StreamSubscription<YoutubePlayerValue>? _controllerSubscription;
  StreamSubscription<YoutubeVideoState>? _videoStateSubscription;
  Timer? _seekDebounceTimer;
  Future<void> _commandQueue = Future<void>.value();
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  bool _isMuted = false;
  bool _hasPlayerState = false;
  bool _isRefreshingDuration = false;
  bool _isSeekInFlight = false;
  bool _isDisposed = false;
  bool? _requestedPlaying;
  int? _pendingSeekMilliseconds;
  int? _activeSeekMilliseconds;
  int? _optimisticSeekMilliseconds;

  CourseYoutubeAdapter(this.controller) {
    _duration = controller.value.metaData.duration;
    _controllerSubscription = controller.listen(_handleControllerValue);
    _videoStateSubscription = controller.videoStateStream.listen(
      _handleVideoState,
    );
  }

  void _handleControllerValue(YoutubePlayerValue value) {
    if (_isDisposed) return;

    final actualIsPlaying = value.playerState == PlayerState.playing;
    if (_requestedPlaying == actualIsPlaying) _requestedPlaying = null;
    if (value.playerState != PlayerState.unknown) {
      _hasPlayerState = true;
    }
    if (value.metaData.duration > Duration.zero) {
      _duration = value.metaData.duration;
    } else if (_hasPlayerState) {
      _refreshDuration();
    }

    if (value.error != YoutubeError.none) {
      _debugLog(
        'Player error code=${value.error.code} error=${value.error.name} '
        'state=${value.playerState.name} positionMs=${_position.inMilliseconds} '
        'durationMs=${_duration.inMilliseconds} buffering=$isBuffering',
      );
    }

    _flushPendingSeek();
    notifyListeners();
  }

  void _handleVideoState(YoutubeVideoState state) {
    if (_isDisposed) return;
    _position = state.position;
    final optimisticSeek = _optimisticSeekMilliseconds;
    if (optimisticSeek != null &&
        (state.position.inMilliseconds - optimisticSeek).abs() <= 1500) {
      _optimisticSeekMilliseconds = null;
    }
    notifyListeners();
  }

  Future<void> _refreshDuration() async {
    if (_isRefreshingDuration || _isDisposed) return;
    _isRefreshingDuration = true;
    try {
      final seconds = await controller.duration;
      if (_isDisposed || !seconds.isFinite || seconds <= 0) return;
      _duration = Duration(milliseconds: (seconds * 1000).round());
      _flushPendingSeek();
      notifyListeners();
    } catch (error) {
      _debugLog('Duration lookup failed: $error');
    } finally {
      _isRefreshingDuration = false;
    }
  }

  void _debugLog(String message) {
    if (kDebugMode) developer.log(message, name: 'CourseYoutubePlayer');
  }

  Future<void> _enqueueCommand(String name, Future<void> Function() command) {
    final queued = _commandQueue.then((_) async {
      if (_isDisposed) return;
      try {
        await command();
      } catch (error) {
        _debugLog('$name command failed: $error');
      }
    });
    _commandQueue = queued;
    return queued;
  }

  @override
  bool get isPlaying => controller.value.playerState == PlayerState.playing;

  @override
  bool get isBuffering => controller.value.playerState == PlayerState.buffering;

  @override
  Duration get position => _position;

  @override
  Duration? get pendingSeekPosition {
    final milliseconds = _optimisticSeekMilliseconds;
    return milliseconds == null ? null : Duration(milliseconds: milliseconds);
  }

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
  bool get isMuted => _isMuted;

  @override
  double get playbackSpeed => _playbackSpeed;

  @override
  void pause() {
    _requestedPlaying = false;
    _enqueueCommand('pause', controller.pauseVideo);
  }

  @override
  void play() {
    _requestedPlaying = true;
    _enqueueCommand('play', controller.playVideo);
  }

  @override
  void togglePlayPause() {
    (_requestedPlaying ?? isPlaying) ? pause() : play();
  }

  @override
  void seekTo(Duration pos) {
    _queueSeek(pos.inMilliseconds);
  }

  @override
  void seekBy(Duration offset) {
    final baseMilliseconds =
        _pendingSeekMilliseconds ??
        _activeSeekMilliseconds ??
        _optimisticSeekMilliseconds ??
        _position.inMilliseconds;
    _queueSeek(baseMilliseconds + offset.inMilliseconds);
  }

  void _queueSeek(int requestedMilliseconds) {
    if (_isDisposed) return;
    final clampedMilliseconds = requestedMilliseconds
        .clamp(
          0,
          _duration > Duration.zero ? _duration.inMilliseconds : 0x7fffffff,
        )
        .toInt();
    _pendingSeekMilliseconds = clampedMilliseconds;
    _optimisticSeekMilliseconds = clampedMilliseconds;
    _debugLog(
      'Seek queued targetMs=$clampedMilliseconds positionMs=${_position.inMilliseconds} '
      'durationMs=${_duration.inMilliseconds} state=${controller.value.playerState.name} '
      'buffering=$isBuffering',
    );
    notifyListeners();
    _seekDebounceTimer?.cancel();
    _seekDebounceTimer = Timer(_seekDebounceDuration, () {
      _seekDebounceTimer = null;
      _flushPendingSeek();
    });
  }

  void _flushPendingSeek() {
    if (_isDisposed || _isSeekInFlight || _pendingSeekMilliseconds == null) {
      return;
    }
    if (_seekDebounceTimer?.isActive ?? false) return;
    if (!_hasPlayerState || _duration <= Duration.zero) {
      if (_hasPlayerState) _refreshDuration();
      return;
    }

    final targetMilliseconds = _pendingSeekMilliseconds!
        .clamp(0, _duration.inMilliseconds)
        .toInt();
    _optimisticSeekMilliseconds = targetMilliseconds;
    _pendingSeekMilliseconds = null;
    _activeSeekMilliseconds = targetMilliseconds;
    _isSeekInFlight = true;
    final stopwatch = Stopwatch()..start();

    _enqueueCommand('seek', () {
      return controller.seekTo(
        seconds: targetMilliseconds / 1000,
        allowSeekAhead: true,
      );
    }).whenComplete(() {
      stopwatch.stop();
      _debugLog(
        'Seek dispatched targetMs=$targetMilliseconds '
        'elapsedMs=${stopwatch.elapsedMilliseconds} '
        'state=${controller.value.playerState.name} '
        'buffering=$isBuffering positionMs=${_position.inMilliseconds} '
        'durationMs=${_duration.inMilliseconds}',
      );
      _activeSeekMilliseconds = null;
      _isSeekInFlight = false;
      if (_pendingSeekMilliseconds != null) _flushPendingSeek();
    });
  }

  @override
  void setVolume(double vol) {
    final wasMuted = _isMuted;
    final normalizedVolume = vol.clamp(0.0, 1.0);
    _volume = normalizedVolume;
    _isMuted = _volume == 0;
    _enqueueCommand(
      'volume',
      () => controller.setVolume((normalizedVolume * 100).round()),
    );
    if (normalizedVolume > 0 && wasMuted) {
      _enqueueCommand('unmute', controller.unMute);
      _isMuted = false;
    }
    notifyListeners();
  }

  @override
  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    _enqueueCommand('playback rate', () => controller.setPlaybackRate(speed));
    notifyListeners();
  }

  @override
  void toggleMute() {
    if (_isMuted || _volume == 0) {
      _enqueueCommand('unmute', controller.unMute);
      _isMuted = false;
      if (_volume == 0) _volume = 1.0;
    } else {
      _enqueueCommand('mute', controller.mute);
      _isMuted = true;
    }
    notifyListeners();
  }

  @override
  void disposeAdapter() {
    _isDisposed = true;
    _seekDebounceTimer?.cancel();
    _controllerSubscription?.cancel();
    _videoStateSubscription?.cancel();
  }
}

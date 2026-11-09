import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/adapters/course_video_adapter.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/adapters/course_youtube_adapter.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/controls/course_video_bottom_controls.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/controls/course_video_buffering_indicator.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/controls/course_video_player_view.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_player_manager.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class FakeYoutubePlayerController implements YoutubePlayerController {
  final StreamController<YoutubePlayerValue> _values =
      StreamController<YoutubePlayerValue>.broadcast();
  final StreamController<YoutubeVideoState> _videoStates =
      StreamController<YoutubeVideoState>.broadcast();
  final List<String> playbackCommands = [];
  final List<double> seekTargets = [];
  final List<bool> seekAheadFlags = [];
  Completer<void>? closeGate;
  int closeCount = 0;

  YoutubePlayerValue _value = YoutubePlayerValue();

  @override
  YoutubePlayerValue get value => _value;

  @override
  Stream<YoutubeVideoState> get videoStateStream => _videoStates.stream;

  @override
  StreamSubscription<YoutubePlayerValue> listen(
    void Function(YoutubePlayerValue)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _values.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Future<double> get duration async =>
      _value.metaData.duration.inMilliseconds / 1000;

  @override
  Future<void> playVideo() async => playbackCommands.add('play');

  @override
  Future<void> pauseVideo() async => playbackCommands.add('pause');

  @override
  Future<void> seekTo({
    required double seconds,
    bool allowSeekAhead = false,
  }) async {
    seekTargets.add(seconds);
    seekAheadFlags.add(allowSeekAhead);
  }

  void emitPlayerState(
    PlayerState state, {
    Duration duration = const Duration(minutes: 60),
    YoutubeError error = YoutubeError.none,
  }) {
    _value = YoutubePlayerValue(
      playerState: state,
      error: error,
      metaData: YoutubeMetaData(duration: duration),
    );
    _values.add(_value);
  }

  void emitPosition(Duration position) {
    _videoStates.add(YoutubeVideoState(position: position));
  }

  Future<void> dispose() async {
    await _values.close();
    await _videoStates.close();
  }

  @override
  Future<void> close() async {
    closeCount++;
    await closeGate?.future;
    await dispose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class FakeControlsAdapter extends CourseVideoAdapter {
  final List<Duration> seeks = [];
  bool muted = false;
  bool buffering = false;
  bool playing = false;

  @override
  bool get isPlaying => playing;

  @override
  bool get isBuffering => buffering;

  @override
  Duration get position => const Duration(minutes: 2);

  @override
  Duration? pendingSeekPosition;

  @override
  Duration get duration => const Duration(hours: 1);

  @override
  double get volume => 1;

  @override
  bool get isMuted => muted;

  @override
  double get playbackSpeed => 1;

  @override
  void play() {}

  @override
  void pause() {}

  @override
  void togglePlayPause() {}

  @override
  void seekTo(Duration position) {
    seeks.add(position);
    pendingSeekPosition = position;
    notifyListeners();
  }

  @override
  void setVolume(double volume) {}

  @override
  void setPlaybackSpeed(double speed) {}

  @override
  void toggleMute() {
    muted = !muted;
    notifyListeners();
  }

  @override
  void disposeAdapter() {}
}

Future<void> settleSeekTimer(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 120));
  await tester.pump();
}

void main() {
  testWidgets('serializes rapid play and pause commands', (tester) async {
    final controller = FakeYoutubePlayerController();
    final adapter = CourseYoutubeAdapter(controller);
    controller.emitPlayerState(PlayerState.paused);
    await tester.pump();

    adapter.play();
    adapter.togglePlayPause();
    await tester.pump();

    expect(controller.playbackCommands, ['play', 'pause']);
    adapter.disposeAdapter();
    await controller.dispose();
  });

  testWidgets('coalesces rapid ten-second skips into one cumulative seek', (
    tester,
  ) async {
    final controller = FakeYoutubePlayerController();
    final adapter = CourseYoutubeAdapter(controller);
    controller.emitPlayerState(PlayerState.playing);
    controller.emitPosition(const Duration(seconds: 120));
    await tester.pump();

    adapter.seekBy(const Duration(seconds: 10));
    adapter.seekBy(const Duration(seconds: 10));
    adapter.seekBy(const Duration(seconds: 10));
    await settleSeekTimer(tester);

    expect(controller.seekTargets, [150]);
    expect(controller.seekAheadFlags, [true]);
    adapter.disposeAdapter();
    await controller.dispose();
  });

  testWidgets('continues accumulating skips after each command is sent', (
    tester,
  ) async {
    final controller = FakeYoutubePlayerController();
    final adapter = CourseYoutubeAdapter(controller);
    controller.emitPlayerState(PlayerState.playing);
    controller.emitPosition(const Duration(seconds: 120));
    await tester.pump();

    adapter.seekBy(const Duration(seconds: 10));
    await settleSeekTimer(tester);
    adapter.seekBy(const Duration(seconds: 10));
    await settleSeekTimer(tester);
    adapter.seekBy(const Duration(seconds: 10));
    await settleSeekTimer(tester);

    expect(controller.seekTargets, [130, 140, 150]);
    expect(adapter.pendingSeekPosition, const Duration(seconds: 150));
    adapter.disposeAdapter();
    await controller.dispose();
  });

  testWidgets('clamps backward and forward seeks to video boundaries', (
    tester,
  ) async {
    final controller = FakeYoutubePlayerController();
    final adapter = CourseYoutubeAdapter(controller);
    controller.emitPlayerState(PlayerState.playing);
    controller.emitPosition(const Duration(seconds: 5));
    await tester.pump();

    adapter.seekBy(const Duration(seconds: -10));
    await settleSeekTimer(tester);
    adapter.seekTo(const Duration(minutes: 60));
    await settleSeekTimer(tester);

    expect(controller.seekTargets, [0, 3600]);
    adapter.disposeAdapter();
    await controller.dispose();
  });

  testWidgets('supports long seeks through the final minute', (tester) async {
    final controller = FakeYoutubePlayerController();
    final adapter = CourseYoutubeAdapter(controller);
    controller.emitPlayerState(PlayerState.paused);
    await tester.pump();

    for (final seconds in [10, 30, 60, 300, 600, 1200, 3540]) {
      adapter.seekTo(Duration(seconds: seconds));
      await settleSeekTimer(tester);
    }

    expect(controller.seekTargets, [10, 30, 60, 300, 600, 1200, 3540]);
    expect(controller.playbackCommands, isEmpty);
    adapter.disposeAdapter();
    await controller.dispose();
  });

  testWidgets('waits for player readiness before issuing a seek', (
    tester,
  ) async {
    final controller = FakeYoutubePlayerController();
    final adapter = CourseYoutubeAdapter(controller);

    adapter.seekTo(const Duration(minutes: 10));
    await settleSeekTimer(tester);
    expect(controller.seekTargets, isEmpty);

    controller.emitPlayerState(PlayerState.buffering);
    await tester.pump();

    expect(adapter.isBuffering, isTrue);
    expect(controller.seekTargets, [600]);
    adapter.disposeAdapter();
    await controller.dispose();
  });

  testWidgets('seeking while buffering does not change play or pause state', (
    tester,
  ) async {
    final controller = FakeYoutubePlayerController();
    final adapter = CourseYoutubeAdapter(controller);
    controller.emitPlayerState(PlayerState.buffering);
    await tester.pump();

    adapter.seekTo(const Duration(minutes: 10));
    await settleSeekTimer(tester);

    expect(controller.seekTargets, [600]);
    expect(controller.playbackCommands, isEmpty);
    adapter.disposeAdapter();
    await controller.dispose();
  });

  testWidgets(
    'double-tapping right side seeks and updates target immediately',
    (tester) async {
      final controller = FakeYoutubePlayerController();
      final adapter = CourseYoutubeAdapter(controller);
      controller.emitPlayerState(PlayerState.playing);
      controller.emitPosition(const Duration(minutes: 3));
      await tester.pump();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(420, 910),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 640,
                height: 360,
                child: CourseVideoPlayerView(
                  adapter: adapter,
                  isFullScreen: false,
                  onToggleFullScreen: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tapAt(const Offset(430, 120));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(const Offset(600, 230));
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        adapter.pendingSeekPosition,
        const Duration(minutes: 3, seconds: 10),
      );
      final progressSlider = tester.widget<Slider>(find.byType(Slider));
      expect(progressSlider.value, greaterThan(180 / 3600));
      expect(find.text('03:10 / 1:00:00'), findsOneWidget);
      await settleSeekTimer(tester);
      expect(controller.seekTargets, [190]);

      await tester.tapAt(const Offset(30, 240));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(const Offset(250, 100));
      await tester.pump();

      expect(adapter.pendingSeekPosition, const Duration(minutes: 3));
      await settleSeekTimer(tester);
      expect(controller.seekTargets, [190, 180]);

      await tester.tapAt(const Offset(430, 120));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(const Offset(600, 230));
      await tester.pump(const Duration(milliseconds: 50));
      expect(
        adapter.pendingSeekPosition,
        const Duration(minutes: 3, seconds: 10),
      );
      await settleSeekTimer(tester);
      expect(controller.seekTargets, [190, 180, 190]);

      adapter.disposeAdapter();
      await controller.dispose();
    },
  );

  testWidgets('center YouTube pause button pauses with one tap', (
    tester,
  ) async {
    final controller = FakeYoutubePlayerController();
    final adapter = CourseYoutubeAdapter(controller);
    controller.emitPlayerState(PlayerState.playing);
    await tester.pump();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(420, 910),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 640,
              height: 360,
              child: CourseVideoPlayerView(
                adapter: adapter,
                isFullScreen: false,
                onToggleFullScreen: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(320, 180));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byTooltip('إيقاف الفيديو'), findsOneWidget);
    final centerSurface = tester.widget<Material>(
      find.byKey(const ValueKey('youtube-center-control-surface')),
    );
    expect(centerSurface.color, Colors.black.withValues(alpha: 0.38));
    expect(
      tester
          .getSize(find.byKey(const ValueKey('youtube-center-control-surface')))
          .width,
      60,
    );
    final centerButton = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'إيقاف الفيديو',
      ),
    );
    expect(centerButton.iconSize, 32);

    await tester.tap(find.byTooltip('إيقاف الفيديو'));
    await tester.pump();

    expect(controller.playbackCommands, contains('pause'));
    adapter.disposeAdapter();
    await controller.dispose();
  });

  testWidgets('keeps the target position visible until the player catches up', (
    tester,
  ) async {
    final controller = FakeYoutubePlayerController();
    final adapter = CourseYoutubeAdapter(controller);
    controller.emitPlayerState(PlayerState.buffering);
    await tester.pump();

    adapter.seekTo(const Duration(minutes: 10));
    expect(adapter.pendingSeekPosition, const Duration(minutes: 10));
    await settleSeekTimer(tester);
    expect(adapter.pendingSeekPosition, const Duration(minutes: 10));

    controller.emitPosition(const Duration(minutes: 10));
    await tester.pump();
    expect(adapter.pendingSeekPosition, isNull);

    adapter.disposeAdapter();
    await controller.dispose();
  });

  testWidgets('does not notify after adapter subscriptions are disposed', (
    tester,
  ) async {
    final controller = FakeYoutubePlayerController();
    final adapter = CourseYoutubeAdapter(controller);
    var notifications = 0;
    adapter.addListener(() => notifications++);
    adapter.disposeAdapter();
    controller.emitPlayerState(PlayerState.playing);
    await tester.pump();

    expect(notifications, 0);
    await controller.dispose();
  });

  test('recognizes documented YouTube errors and unknown code 153', () {
    expect(YoutubeError.fromCode(2), YoutubeError.invalidParam);
    expect(YoutubeError.fromCode(5), YoutubeError.html5Error);
    expect(YoutubeError.fromCode(100), YoutubeError.videoNotFound);
    expect(YoutubeError.fromCode(101), YoutubeError.notEmbeddable);
    expect(YoutubeError.fromCode(150), YoutubeError.sameAsNotEmbeddable);
    expect(YoutubeError.fromCode(153), YoutubeError.unknown);
  });

  test(
    'reuses the controller for the same lesson and closes it on change',
    () async {
      final controllers = <FakeYoutubePlayerController>[];
      final manager = CourseVideoPlayerManager(
        hasInternetConnection: () async => true,
        enableScreenProtection: () async {},
        disableScreenProtection: () async {},
        youtubeControllerFactory: (_, _) {
          final controller = FakeYoutubePlayerController();
          controllers.add(controller);
          return controller;
        },
      );

      const firstUrl = 'https://www.youtube.com/watch?v=abcdefghijk';
      await manager.initPlayer(firstUrl);
      await manager.initPlayer(firstUrl);

      expect(controllers, hasLength(1));

      await manager.initPlayer('https://www.youtube.com/watch?v=lmnopqrstuv');
      expect(controllers, hasLength(2));
      expect(controllers.first.closeCount, 1);

      await manager.initPlayer(null);
      expect(controllers.last.closeCount, 1);
    },
  );

  test(
    'stale lesson initialization cannot recreate a controller after A-B-A',
    () async {
      final controllers = <FakeYoutubePlayerController>[];
      final manager = CourseVideoPlayerManager(
        hasInternetConnection: () async => true,
        enableScreenProtection: () async {},
        disableScreenProtection: () async {},
        youtubeControllerFactory: (_, _) {
          final controller = FakeYoutubePlayerController();
          controllers.add(controller);
          return controller;
        },
      );

      const lessonA = 'https://www.youtube.com/watch?v=abcdefghijk';
      await manager.initPlayer(lessonA);
      controllers.first.closeGate = Completer<void>();

      final staleLessonB = manager.initPlayer(
        'https://www.youtube.com/watch?v=lmnopqrstuv',
      );
      await Future<void>.delayed(Duration.zero);
      expect(controllers.first.closeCount, 1);

      await manager.initPlayer(lessonA);
      expect(controllers, hasLength(2));

      controllers.first.closeGate!.complete();
      await staleLessonB;
      expect(controllers, hasLength(2));
      expect(manager.ytController, same(controllers.last));

      await manager.initPlayer(null);
      expect(controllers.last.closeCount, 1);
    },
  );

  testWidgets('slider drag commits only one seek when released', (
    tester,
  ) async {
    final adapter = FakeControlsAdapter();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(420, 910),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 240,
              child: Stack(
                children: [
                  CourseVideoBottomControls(
                    adapter: adapter,
                    isFullScreen: false,
                    onToggleFullScreen: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final slider = find.byType(Slider);
    final gesture = await tester.startGesture(tester.getCenter(slider));
    await gesture.moveBy(const Offset(100, 0));
    await tester.pump();
    expect(adapter.seeks, isEmpty);

    await gesture.up();
    await tester.pump();
    expect(adapter.seeks, hasLength(1));
    expect(adapter.seeks.single, greaterThan(const Duration(minutes: 2)));
    expect(
      tester.widget<Slider>(slider).value,
      closeTo(
        adapter.seeks.single.inMilliseconds / adapter.duration.inMilliseconds,
        0.01,
      ),
    );
  });

  testWidgets('mute button reflects the current muted state', (tester) async {
    final adapter = FakeControlsAdapter();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(420, 910),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 240,
              child: Stack(
                children: [
                  CourseVideoBottomControls(
                    adapter: adapter,
                    isFullScreen: false,
                    onToggleFullScreen: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('كتم الصوت'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    adapter.muted = true;
    adapter.notifyListeners();
    await tester.pump();
    expect(find.byTooltip('إلغاء كتم الصوت'), findsOneWidget);
    expect(find.byIcon(Icons.volume_off), findsOneWidget);
  });

  testWidgets('buffering indicator appears immediately even while playing', (
    tester,
  ) async {
    final adapter = FakeControlsAdapter()..playing = true;
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [CourseVideoBufferingIndicator(adapter: adapter)],
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('course-video-buffering-spinner')),
      findsNothing,
    );
    adapter.buffering = true;
    adapter.notifyListeners();
    await tester.pump();

    expect(
      find.byKey(const ValueKey('course-video-buffering-spinner')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

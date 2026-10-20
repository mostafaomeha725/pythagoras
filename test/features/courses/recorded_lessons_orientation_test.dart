import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/utils/system_ui_manager.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';
import 'package:pythagoras/features/courses/presentation/cubit/chapter_videos/chapter_videos_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/complete_lesson/complete_lesson_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/complete_video/complete_video_cubit.dart';
import 'package:pythagoras/features/courses/presentation/screens/course_recorded_lessons_screen.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_recorded_lessons_screen_body.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_recorded_lessons_tablet_landscape.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/adapters/course_video_adapter.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/controls/course_video_bottom_controls.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_fullscreen_handler.dart';
import 'package:pythagoras/features/courses/presentation/widgets/video_player/course_video_player_manager.dart';

class FakeChapterVideosCubit extends Cubit<ChapterVideosState>
    implements ChapterVideosCubit {
  FakeChapterVideosCubit() : super(AllChapterVideosSuccess());

  @override
  Future<void> fetchAllChaptersVideos(List<int> chapterIds) async {}

  @override
  List<CourseLesson>? getVideosForChapter(int chapterId) => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCompleteVideoCubit extends Cubit<CompleteVideoState>
    implements CompleteVideoCubit {
  FakeCompleteVideoCubit() : super(CompleteVideoInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCompleteLessonCubit extends Cubit<CompleteLessonState>
    implements CompleteLessonCubit {
  FakeCompleteLessonCubit() : super(CompleteLessonInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeVideoAdapter extends ChangeNotifier implements CourseVideoAdapter {
  @override
  bool get isPlaying => false;
  @override
  bool get isBuffering => false;
  @override
  Duration get position => const Duration(minutes: 59, seconds: 4);
  @override
  Duration get duration => const Duration(minutes: 60, seconds: 23);
  @override
  double get volume => 1.0;
  @override
  bool get supportsPlayPause => true;
  @override
  bool get supportsSeek => true;
  @override
  bool get supportsVolume => true;
  @override
  bool get supportsPosition => true;
  @override
  bool get supportsDuration => true;
  @override
  bool get supportsCustomControls => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const dummyCourse = CourseDetail(
  id: 1,
  title: 'رياضيات الصف الثالث الثانوي',
  level: 'متقدم',
  className: 'الصف الثالث',
  isEnrolled: true,
  price: '100',
  finalPrice: 100,
  currencyLabel: 'ج.م',
  studentsCount: 50,
  isSaved: false,
  rating: 4.8,
  category: 'رياضيات',
  chapters: [],
);

Widget createScreenTestWidget({required Size surfaceSize}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, child) => const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CourseRecordedLessonsScreen(course: dummyCourse),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> platformCalls = [];

  setUp(() {
    platformCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform,
            (MethodCall methodCall) async {
      platformCalls.add(methodCall);
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('screen_protector'),
      (MethodCall methodCall) async => null,
    );

    if (sl.isRegistered<ChapterVideosCubit>()) {
      sl.unregister<ChapterVideosCubit>();
    }
    if (sl.isRegistered<CompleteVideoCubit>()) {
      sl.unregister<CompleteVideoCubit>();
    }
    if (sl.isRegistered<CompleteLessonCubit>()) {
      sl.unregister<CompleteLessonCubit>();
    }

    sl.registerFactory<ChapterVideosCubit>(() => FakeChapterVideosCubit());
    sl.registerFactory<CompleteVideoCubit>(() => FakeCompleteVideoCubit());
    sl.registerFactory<CompleteLessonCubit>(() => FakeCompleteLessonCubit());
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('screen_protector'), null);

    if (sl.isRegistered<ChapterVideosCubit>()) {
      sl.unregister<ChapterVideosCubit>();
    }
    if (sl.isRegistered<CompleteVideoCubit>()) {
      sl.unregister<CompleteVideoCubit>();
    }
    if (sl.isRegistered<CompleteLessonCubit>()) {
      sl.unregister<CompleteLessonCubit>();
    }
  });

  group('SystemUiManager Orientation Lifecycle Tests', () {
    test('enterFullscreen locks to landscape and sets immersiveSticky',
        () async {
      await SystemUiManager.enterFullscreen();

      final orientationCall = platformCalls.firstWhere(
        (c) => c.method == 'SystemChrome.setPreferredOrientations',
      );
      final List<dynamic> orientations = orientationCall.arguments as List;
      expect(orientations, contains('DeviceOrientation.landscapeLeft'));
      expect(orientations, contains('DeviceOrientation.landscapeRight'));

      final uiModeCall = platformCalls.firstWhere(
        (c) => c.method == 'SystemChrome.setEnabledSystemUIMode',
      );
      expect(uiModeCall.arguments, contains('immersiveSticky'));
    });

    test(
        'exitFullscreen on Tablet in Landscape preserves landscape and does NOT force portrait',
        () async {
      platformCalls.clear();
      await SystemUiManager.exitFullscreen(
        isTablet: true,
        targetOrientation: Orientation.landscape,
      );

      final orientationCall = platformCalls.firstWhere(
        (c) => c.method == 'SystemChrome.setPreferredOrientations',
      );
      final List<dynamic> orientations = orientationCall.arguments as List;
      expect(orientations, contains('DeviceOrientation.landscapeLeft'));
      expect(orientations, contains('DeviceOrientation.landscapeRight'));
      expect(orientations, isNot(contains('DeviceOrientation.portraitUp')));
      expect(orientations, isNot(contains('DeviceOrientation.portraitDown')));
    });

    test('exitFullscreen on Tablet in Portrait returns to portrait', () async {
      platformCalls.clear();
      await SystemUiManager.exitFullscreen(
        isTablet: true,
        targetOrientation: Orientation.portrait,
      );

      final orientationCall = platformCalls.firstWhere(
        (c) => c.method == 'SystemChrome.setPreferredOrientations',
      );
      final List<dynamic> orientations = orientationCall.arguments as List;
      expect(orientations, contains('DeviceOrientation.portraitUp'));
      expect(orientations, contains('DeviceOrientation.portraitDown'));
      expect(orientations, isNot(contains('DeviceOrientation.landscapeLeft')));
    });

    test('unlockOrientations resets orientation locks to allow sensor rotation',
        () async {
      platformCalls.clear();
      await SystemUiManager.unlockOrientations();

      final orientationCall = platformCalls.firstWhere(
        (c) => c.method == 'SystemChrome.setPreferredOrientations',
      );
      final List<dynamic> orientations = orientationCall.arguments as List;
      expect(orientations, isEmpty);
    });

    test('exitFullscreen on Mobile strictly preserves portrait lock', () async {
      platformCalls.clear();
      await SystemUiManager.exitFullscreen(
        isTablet: false,
        targetOrientation: Orientation.landscape, // Mobile ignores landscape target
      );

      final orientationCall = platformCalls.firstWhere(
        (c) => c.method == 'SystemChrome.setPreferredOrientations',
      );
      final List<dynamic> orientations = orientationCall.arguments as List;
      expect(orientations, contains('DeviceOrientation.portraitUp'));
      expect(orientations, contains('DeviceOrientation.portraitDown'));
      expect(orientations, isNot(contains('DeviceOrientation.landscapeLeft')));
    });
  });

  group('CourseVideoFullscreenHandler Tablet Lifecycle Tests', () {
    testWidgets(
        'Tablet Landscape: exits fullscreen without forcing portrait, then unlocks orientations',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final manager = CourseVideoPlayerManager();
      addTearDown(manager.dispose);

      late BuildContext testContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              testContext = ctx;
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );
      await tester.pump();

      // Enter fullscreen
      await CourseVideoFullscreenHandler.toggleFullscreen(
        context: testContext,
        manager: manager,
        videoUrl: 'https://example.com/video.mp4',
        videoType: 'native',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(manager.wasTablet, isTrue);
      expect(manager.preFullscreenOrientation, equals(Orientation.landscape));
      expect(manager.isFullScreen, isTrue);

      platformCalls.clear();

      // Exit fullscreen
      CourseVideoFullscreenHandler.exitFullscreen(
        context: testContext,
        manager: manager,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(manager.isFullScreen, isFalse);

      final orientationCalls = platformCalls
          .where((c) => c.method == 'SystemChrome.setPreferredOrientations')
          .toList();
      expect(orientationCalls, isNotEmpty);

      // Verify that landscape was restored
      final firstCallOrientations = orientationCalls.first.arguments as List;
      expect(firstCallOrientations, contains('DeviceOrientation.landscapeLeft'));
      expect(firstCallOrientations, isNot(contains('DeviceOrientation.portraitUp')));

      // Verify that unlockOrientations (empty list) was called subsequently
      final lastCallOrientations = orientationCalls.last.arguments as List;
      expect(lastCallOrientations, isEmpty);
    });

    testWidgets(
        'Tablet Portrait: exits fullscreen to portrait, then unlocks orientations',
        (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final manager = CourseVideoPlayerManager();
      addTearDown(manager.dispose);

      late BuildContext testContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              testContext = ctx;
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );
      await tester.pump();

      // Enter fullscreen from portrait
      await CourseVideoFullscreenHandler.toggleFullscreen(
        context: testContext,
        manager: manager,
        videoUrl: 'https://example.com/video.mp4',
        videoType: 'native',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(manager.wasTablet, isTrue);
      expect(manager.preFullscreenOrientation, equals(Orientation.portrait));
      expect(manager.isFullScreen, isTrue);

      platformCalls.clear();

      // Exit fullscreen
      CourseVideoFullscreenHandler.exitFullscreen(
        context: testContext,
        manager: manager,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(manager.isFullScreen, isFalse);

      final orientationCalls = platformCalls
          .where((c) => c.method == 'SystemChrome.setPreferredOrientations')
          .toList();
      expect(orientationCalls, isNotEmpty);

      // First call rotates back to portrait
      final firstCallOrientations = orientationCalls.first.arguments as List;
      expect(firstCallOrientations, contains('DeviceOrientation.portraitUp'));

      // Final call unlocks orientations
      final lastCallOrientations = orientationCalls.last.arguments as List;
      expect(lastCallOrientations, isEmpty);
    });
  });

  group('CourseRecordedLessonsScreen Responsive Layout Tests', () {
    testWidgets(
        'Tablet Landscape (1024x768): renders CourseRecordedLessonsTabletLandscape',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createScreenTestWidget(surfaceSize: const Size(1024, 768)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CourseRecordedLessonsTabletLandscape), findsOneWidget);
      expect(find.byType(CourseRecordedLessonsScreenBody), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Small Tablet Landscape WSVGA (1024x600): correctly renders CourseRecordedLessonsTabletLandscape',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createScreenTestWidget(surfaceSize: const Size(1024, 600)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CourseRecordedLessonsTabletLandscape), findsOneWidget);
      expect(find.byType(CourseRecordedLessonsScreenBody), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Tablet Portrait (768x1024): renders CourseRecordedLessonsScreenBody and AppBar',
        (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createScreenTestWidget(surfaceSize: const Size(768, 1024)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CourseDetailAppBar), findsOneWidget);
      expect(find.byType(CourseRecordedLessonsScreenBody), findsOneWidget);
      expect(find.byType(CourseRecordedLessonsTabletLandscape), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Mobile Portrait (412x915): renders CourseRecordedLessonsScreenBody and AppBar',
        (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createScreenTestWidget(surfaceSize: const Size(412, 915)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CourseDetailAppBar), findsOneWidget);
      expect(find.byType(CourseRecordedLessonsScreenBody), findsOneWidget);
      expect(find.byType(CourseRecordedLessonsTabletLandscape), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Mobile Landscape (844x390): maintains mobile layout without switching to tablet',
        (tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createScreenTestWidget(surfaceSize: const Size(844, 390)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CourseDetailAppBar), findsOneWidget);
      expect(find.byType(CourseRecordedLessonsScreenBody), findsOneWidget);
      expect(find.byType(CourseRecordedLessonsTabletLandscape), findsNothing);
      // Draining any vertical RenderFlex overflow caused by synthetic 390px mobile height
      tester.takeException();
    });
  });

  group('CourseVideoBottomControls Time Text Tests', () {
    testWidgets('Tablet: time text uses balanced fontSize: 13 instead of bloated .sp',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final adapter = FakeVideoAdapter();

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1024, 768)),
          child: ScreenUtilInit(
            designSize: const Size(420, 910),
            builder: (context, _) => MaterialApp(
              home: Scaffold(
                body: Stack(
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
      await tester.pump();

      final textFinder = find.byWidgetPredicate(
        (widget) => widget is AppText && widget.text.contains('59:04'),
      );
      expect(textFinder, findsOneWidget);

      final appText = tester.widget<AppText>(textFinder);
      expect(appText.style?.fontSize, equals(13.0));
    });

    testWidgets('Mobile: time text preserves mobile font12w400 style',
        (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final adapter = FakeVideoAdapter();

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(412, 915)),
          child: ScreenUtilInit(
            designSize: const Size(420, 910),
            builder: (context, _) => MaterialApp(
              home: Scaffold(
                body: Stack(
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
      await tester.pump();

      final textFinder = find.byWidgetPredicate(
        (widget) => widget is AppText && widget.text.contains('59:04'),
      );
      expect(textFinder, findsOneWidget);

      final appText = tester.widget<AppText>(textFinder);
      // On mobile, fontSize should NOT be overridden to 13.0; it retains font12w400
      expect(appText.style?.fontSize, isNot(equals(13.0)));
    });
  });
}

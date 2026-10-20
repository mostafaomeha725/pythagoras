import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_state.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_state.dart';
import 'package:pythagoras/features/profile/presentation/screens/profile_screen.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_tablet_header_badges.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_tablet_header_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_tablet_landscape.dart';

class FakeProfileCubit extends Cubit<ProfileState> implements ProfileCubit {
  FakeProfileCubit() : super(ProfileInitial());
  @override
  Future<void> getAccountInfo() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCoursesListCubit extends Cubit<CoursesListState>
    implements CoursesListCubit {
  FakeCoursesListCubit() : super(CoursesListInitial());
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget createTestWidget({required Size surfaceSize}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, _) => MultiBlocProvider(
        providers: [
          BlocProvider<ProfileCubit>(create: (_) => FakeProfileCubit()),
          BlocProvider<CoursesListCubit>(create: (_) => FakeCoursesListCubit()),
        ],
        child: const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: ProfileScreen(),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'userToken': 'valid_token'});
    final prefs = await SharedPreferences.getInstance();
    if (sl.isRegistered<PreferencesStorage>()) {
      sl.unregister<PreferencesStorage>();
    }
    sl.registerLazySingleton<PreferencesStorage>(() => PreferencesStorage(prefs));
  });

  tearDown(() {
    if (sl.isRegistered<PreferencesStorage>()) {
      sl.unregister<PreferencesStorage>();
    }
  });

  group('ProfileScreen Responsive Tests', () {
    testWidgets('Mobile Portrait (412x915) renders mobile AppBar and ProfileHeaderCard without badges', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(412, 915)));
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ProfileHeaderCard), findsOneWidget);
      expect(find.byType(ProfileTabletLandscape), findsNothing);
      expect(find.byType(ProfileTabletHeaderBadges), findsNothing);
      expect(find.text('حساب الطالب: نشط ومسجل'), findsNothing);
      expect(find.text('منصة فيثاغورس التعليمية'), findsNothing);
      expect(find.text('v1.0.0'), findsNothing);
    });

    testWidgets('Mobile Landscape (844x390) renders mobile layout without badges', (tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(844, 390)));
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ProfileHeaderCard), findsOneWidget);
      expect(find.byType(ProfileTabletLandscape), findsNothing);
      expect(find.byType(ProfileTabletHeaderBadges), findsNothing);
      expect(find.text('حساب الطالب: نشط ومسجل'), findsNothing);
      expect(find.text('منصة فيثاغورس التعليمية'), findsNothing);
      expect(find.text('v1.0.0'), findsNothing);
    });

    testWidgets('Small Tablet Portrait (768x1024) hides account information badges and divider completely', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(768, 1024)));
      await tester.pump();

      expect(find.byType(ProfileTabletLandscape), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(ProfileTabletHeaderCard), findsOneWidget);
      // Badges must be hidden completely without leftover divider or empty space
      expect(find.byType(ProfileTabletHeaderBadges), findsNothing);
      expect(find.text('حساب الطالب: نشط ومسجل'), findsNothing);
      expect(find.text('منصة فيثاغورس التعليمية'), findsNothing);
      expect(find.text('v1.0.0'), findsNothing);
      expect(find.descendant(of: find.byType(ProfileTabletHeaderCard), matching: find.byType(Divider)), findsNothing);
    });

    testWidgets('7-inch WSVGA Small Tablet Portrait (600x1024) hides account information badges', (tester) async {
      tester.view.physicalSize = const Size(600, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(600, 1024)));
      await tester.pump();

      expect(find.byType(ProfileTabletLandscape), findsOneWidget);
      expect(find.byType(ProfileTabletHeaderCard), findsOneWidget);
      expect(find.byType(ProfileTabletHeaderBadges), findsNothing);
      expect(find.text('حساب الطالب: نشط ومسجل'), findsNothing);
      expect(find.text('منصة فيثاغورس التعليمية'), findsNothing);
      expect(find.text('v1.0.0'), findsNothing);
      expect(find.descendant(of: find.byType(ProfileTabletHeaderCard), matching: find.byType(Divider)), findsNothing);
    });

    testWidgets('Small Tablet Landscape (1024x768) displays account information badges and divider', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(1024, 768)));
      await tester.pump();

      expect(find.byType(ProfileTabletLandscape), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(ProfileTabletHeaderCard), findsOneWidget);
      expect(find.byType(ProfileTabletHeaderBadges), findsOneWidget);
      expect(find.text('حساب الطالب: نشط ومسجل'), findsOneWidget);
      expect(find.text('منصة فيثاغورس التعليمية'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
      expect(find.descendant(of: find.byType(ProfileTabletHeaderCard), matching: find.byType(Divider)), findsOneWidget);
    });

    testWidgets('7-inch WSVGA Small Tablet Landscape (1024x600) displays account information badges', (tester) async {
      tester.view.physicalSize = const Size(1024, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(1024, 600)));
      await tester.pump();

      expect(find.byType(ProfileTabletLandscape), findsOneWidget);
      expect(find.byType(ProfileTabletHeaderCard), findsOneWidget);
      expect(find.byType(ProfileTabletHeaderBadges), findsOneWidget);
      expect(find.text('حساب الطالب: نشط ومسجل'), findsOneWidget);
      expect(find.text('منصة فيثاغورس التعليمية'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
    });

    testWidgets('Large Tablet Landscape (1280x800) displays account information badges and divider', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(1280, 800)));
      await tester.pump();

      expect(find.byType(ProfileTabletLandscape), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(ProfileTabletHeaderCard), findsOneWidget);
      expect(find.byType(ProfileTabletHeaderBadges), findsOneWidget);
      expect(find.text('حساب الطالب: نشط ومسجل'), findsOneWidget);
      expect(find.text('منصة فيثاغورس التعليمية'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
      expect(find.descendant(of: find.byType(ProfileTabletHeaderCard), matching: find.byType(Divider)), findsOneWidget);
    });
  });
}

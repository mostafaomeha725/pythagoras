import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/constants/app_assets.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/widgets/custom_bottom_navbar.dart';
import 'package:pythagoras/core/widgets/navigation_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_state.dart';
import 'package:pythagoras/features/home/screens/home_screen_content.dart';
import 'package:pythagoras/features/home/widgets/home_header.dart';
import 'package:pythagoras/features/home/widgets/home_tablet_landscape.dart';
import 'package:pythagoras/features/home/widgets/tablet_navigation_sidebar.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_state.dart';

class FakeClassesCubit extends Cubit<ClassesState> implements ClassesCubit {
  FakeClassesCubit() : super(ClassesInitial());
  @override
  Future<void> fetchClasses() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCoursesListCubit extends Cubit<CoursesListState>
    implements CoursesListCubit {
  FakeCoursesListCubit() : super(CoursesListInitial());
  @override
  Future<void> fetchCourses() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeProfileCubit extends Cubit<ProfileState> implements ProfileCubit {
  FakeProfileCubit() : super(ProfileInitial());
  @override
  Future<void> getAccountInfo() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget createTestWidget({required Size surfaceSize}) {
  final navState = NavigationState();
  final navItems = [
    {
      'label': 'الرئيسية',
      'icon': Icons.home,
      'imageAsset': Assets.home,
    },
    {
      'label': 'الدورات',
      'icon': Icons.school,
      'imageAsset': Assets.course,
    },
    {
      'label': 'حسابي',
      'icon': Icons.person,
      'imageAsset': Assets.profile,
    },
  ];

  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, _) => MultiBlocProvider(
        providers: [
          BlocProvider<ClassesCubit>(create: (_) => FakeClassesCubit()),
          BlocProvider<CoursesListCubit>(create: (_) => FakeCoursesListCubit()),
          BlocProvider<ProfileCubit>(create: (_) => FakeProfileCubit()),
        ],
        child: MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: HomeScreenContent(
              navState: navState,
              navItems: navItems,
            ),
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

  group('HomeScreen Responsive Tests', () {
    testWidgets('Mobile Portrait (412x915) renders mobile BottomNavBar and HomeHeader', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(412, 915)));
      await tester.pump();

      expect(find.byType(CustomBottomNavBar), findsOneWidget);
      expect(find.byType(HomeHeader), findsOneWidget);
      expect(find.byType(TabletNavigationSidebar), findsNothing);
      expect(find.byType(HomeTabletLandscape), findsNothing);
    });

    testWidgets('Mobile Landscape (844x390) renders mobile layout', (tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(844, 390)));
      await tester.pump();

      expect(find.byType(CustomBottomNavBar), findsOneWidget);
      expect(find.byType(HomeHeader), findsOneWidget);
      expect(find.byType(TabletNavigationSidebar), findsNothing);
      expect(find.byType(HomeTabletLandscape), findsNothing);
    });

    testWidgets('Small Tablet Portrait (768x1024) renders HomeTabletLandscape with BottomNavBar', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(768, 1024)));
      await tester.pump();

      expect(find.byType(CustomBottomNavBar), findsOneWidget);
      expect(find.byType(HomeTabletLandscape), findsOneWidget);
      expect(find.byType(HomeHeader), findsNothing);
    });

    testWidgets('Small Tablet Landscape (1024x768) renders TabletNavigationSidebar and HomeTabletLandscape', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(1024, 768)));
      await tester.pump();

      expect(find.byType(TabletNavigationSidebar), findsOneWidget);
      expect(find.byType(HomeTabletLandscape), findsOneWidget);
      expect(find.byType(CustomBottomNavBar), findsNothing);
    });

    testWidgets('Large Tablet Landscape (1280x800) renders TabletNavigationSidebar and HomeTabletLandscape', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(1280, 800)));
      await tester.pump();

      expect(find.byType(TabletNavigationSidebar), findsOneWidget);
      expect(find.byType(HomeTabletLandscape), findsOneWidget);
      expect(find.byType(CustomBottomNavBar), findsNothing);
    });
  });
}

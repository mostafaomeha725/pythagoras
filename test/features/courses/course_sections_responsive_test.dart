import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/screens/course_sections_screen.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_section_tablet_tile.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_sections_screen_body.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_sections_tablet_landscape.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';

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

Widget createTestWidget({required Size surfaceSize}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, child) => const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CourseSectionsScreen(course: dummyCourse),
        ),
      ),
    ),
  );
}

void main() {
  group('CourseSectionsScreen Responsive Layout Tests', () {
    testWidgets(
      'Mobile Portrait (412x915) displays standard mobile AppBar and body',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(412, 915)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CourseDetailAppBar), findsOneWidget);
        expect(find.byType(CourseSectionsScreenBody), findsOneWidget);
        expect(find.byType(CourseSectionsTabletLandscape), findsNothing);
      },
    );

    testWidgets('Mobile Landscape (844x390) maintains mobile layout', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestWidget(surfaceSize: const Size(844, 390)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CourseDetailAppBar), findsOneWidget);
      expect(find.byType(CourseSectionsScreenBody), findsOneWidget);
      expect(find.byType(CourseSectionsTabletLandscape), findsNothing);
    });

    testWidgets(
      'Small Tablet Portrait (768x1024) renders dedicated tablet layout with 2 columns',
      (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(768, 1024)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CourseSectionsTabletLandscape), findsOneWidget);
        expect(find.byType(CourseDetailAppBar), findsNothing);
        expect(find.byType(CourseSectionTabletTile), findsNWidgets(4));

        final gridFinder = find.byType(GridView);
        expect(gridFinder, findsOneWidget);
        final gridView = tester.widget<GridView>(gridFinder);
        final delegate =
            gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 2);

        expect(find.text('رياضيات الصف الثالث الثانوي'), findsOneWidget);
        expect(find.text('الدروس المسجلة'), findsOneWidget);
        expect(find.text('الإمتحانات والواجبات'), findsOneWidget);
        expect(find.text('الحصص الأونلاين'), findsOneWidget);
        expect(find.text('الموارد'), findsOneWidget);
      },
    );

    testWidgets(
      '7-inch WSVGA Small Tablet Portrait (600x1024) renders with 2 columns and no overflow',
      (tester) async {
        tester.view.physicalSize = const Size(600, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(600, 1024)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CourseSectionsTabletLandscape), findsOneWidget);
        expect(find.byType(CourseSectionTabletTile), findsNWidgets(4));

        final gridFinder = find.byType(GridView);
        final gridView = tester.widget<GridView>(gridFinder);
        final delegate =
            gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 2);
      },
    );

    testWidgets(
      'Small Tablet Landscape (1024x768) renders dedicated tablet layout with 4 columns',
      (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(1024, 768)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CourseSectionsTabletLandscape), findsOneWidget);
        expect(find.byType(CourseDetailAppBar), findsNothing);
        expect(find.byType(CourseSectionTabletTile), findsNWidgets(4));

        final gridFinder = find.byType(GridView);
        expect(gridFinder, findsOneWidget);
        final gridView = tester.widget<GridView>(gridFinder);
        final delegate =
            gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 4);

        expect(find.text('رياضيات الصف الثالث الثانوي'), findsOneWidget);
        expect(find.text('الدروس المسجلة'), findsOneWidget);
        expect(find.text('الإمتحانات والواجبات'), findsOneWidget);
        expect(find.text('الحصص الأونلاين'), findsOneWidget);
        expect(find.text('الموارد'), findsOneWidget);
      },
    );

    testWidgets(
      '7-inch WSVGA Small Tablet Landscape (1024x600) renders all 4 sections in 1 row without cutoff or overflow',
      (tester) async {
        tester.view.physicalSize = const Size(1024, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(1024, 600)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CourseSectionsTabletLandscape), findsOneWidget);
        expect(find.byType(CourseSectionTabletTile), findsNWidgets(4));

        final gridFinder = find.byType(GridView);
        final gridView = tester.widget<GridView>(gridFinder);
        final delegate =
            gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 4);

        expect(find.text('الدروس المسجلة'), findsOneWidget);
        expect(find.text('الإمتحانات والواجبات'), findsOneWidget);
        expect(find.text('الحصص الأونلاين'), findsOneWidget);
        expect(find.text('الموارد'), findsOneWidget);
      },
    );

    testWidgets(
      'Large Tablet Landscape (1280x800) preserves 2-column layout and exact aspect ratio',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(1280, 800)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CourseSectionsTabletLandscape), findsOneWidget);
        expect(find.byType(CourseDetailAppBar), findsNothing);
        expect(find.byType(CourseSectionTabletTile), findsNWidgets(4));

        final gridFinder = find.byType(GridView);
        expect(gridFinder, findsOneWidget);
        final gridView = tester.widget<GridView>(gridFinder);
        final delegate =
            gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 2);
        expect(delegate.childAspectRatio, 2.3);
      },
    );
  });
}

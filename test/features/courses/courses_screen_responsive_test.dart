import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_page_header.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/courses_screen_body.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/courses_tablet_landscape.dart';

class FakeClassesCubit extends Cubit<ClassesState> implements ClassesCubit {
  FakeClassesCubit()
      : super(
          const ClassesLoaded(
            classes: [
              StudentClass(id: 0, name: 'الكل'),
              StudentClass(id: 1, name: 'الصف العاشر'),
            ],
            selectedClass: StudentClass(id: 0, name: 'الكل'),
          ),
        );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCoursesListCubit extends Cubit<CoursesListState>
    implements CoursesListCubit {
  FakeCoursesListCubit() : super(CoursesListLoaded(const []));
  @override
  Future<void> fetchCourses() async {}
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
          BlocProvider<ClassesCubit>(create: (_) => FakeClassesCubit()),
          BlocProvider<CoursesListCubit>(create: (_) => FakeCoursesListCubit()),
        ],
        child: const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: CoursesScreenBody()),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('CoursesScreenBody Responsive Tests', () {
    testWidgets('Mobile Portrait (412x915) renders mobile layout', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestWidget(surfaceSize: const Size(412, 915)),
      );
      await tester.pump();

      expect(find.byType(CoursePageHeader), findsOneWidget);
      expect(find.byType(CoursesTabletLandscape), findsNothing);
    });

    testWidgets('Mobile Landscape (844x390) renders mobile layout', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestWidget(surfaceSize: const Size(844, 390)),
      );
      await tester.pump();

      expect(find.byType(CoursePageHeader), findsOneWidget);
      expect(find.byType(CoursesTabletLandscape), findsNothing);
    });

    testWidgets(
      'Small Tablet Portrait (768x1024) renders CoursesTabletLandscape',
      (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(768, 1024)),
        );
        await tester.pump();

        expect(find.byType(CoursesTabletLandscape), findsOneWidget);
        expect(find.byType(CoursePageHeader), findsNothing);
      },
    );

    testWidgets(
      'Small Tablet Landscape (1024x768) renders CoursesTabletLandscape',
      (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(1024, 768)),
        );
        await tester.pump();

        expect(find.byType(CoursesTabletLandscape), findsOneWidget);
        expect(find.byType(CoursePageHeader), findsNothing);
      },
    );

    testWidgets(
      'Large Tablet Landscape (1280x800) renders CoursesTabletLandscape',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(1280, 800)),
        );
        await tester.pump();

        expect(find.byType(CoursesTabletLandscape), findsOneWidget);
        expect(find.byType(CoursePageHeader), findsNothing);
      },
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/courses/domain/entities/course_attachment.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_resources/course_resources_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_resources/course_resources_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/download_resource/download_resource_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/download_resource/download_resource_state.dart';
import 'package:pythagoras/features/courses/presentation/screens/course_resources_screen.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_resources_screen_body.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_resources_tablet_landscape.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_tablet_resource_card.dart';

class FakeCourseResourcesCubit extends Cubit<CourseResourcesState>
    implements CourseResourcesCubit {
  final List<CourseResource> initialResources;

  FakeCourseResourcesCubit({this.initialResources = const []})
      : super(CourseResourcesLoaded(initialResources));

  @override
  Future<void> getResources(int courseId) async {
    emit(CourseResourcesLoaded(initialResources));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDownloadResourceCubit extends Cubit<DownloadResourceState>
    implements DownloadResourceCubit {
  FakeDownloadResourceCubit() : super(DownloadResourceInitial());

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

const dummyResources = [
  CourseResource(
    id: 101,
    title: 'ملزمة مراجعة ليلة الامتحان',
    description: 'شاملة كل القوانين والنظريات الهامة للمقرر',
    fileUrl: 'https://example.com/math_review.pdf',
    file: CourseAttachment(
      name: 'math_review.pdf',
      url: 'https://example.com/math_review.pdf',
      mimeType: 'application/pdf',
      extension: 'pdf',
      size: 1024 * 1024 * 5,
    ),
  ),
  CourseResource(
    id: 102,
    title: 'ملخص الباب الأول والثاني',
    description: 'ملخص مركز لأهم التمارين المحلولة',
    fileUrl: 'https://example.com/summary.docx',
    file: CourseAttachment(
      name: 'summary.docx',
      url: 'https://example.com/summary.docx',
      mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      extension: 'docx',
      size: 1024 * 1024 * 2,
    ),
  ),
  CourseResource(
    id: 103,
    title: 'خرائط ذهنية لمنهج الأحياء',
    description: 'مخططات توضيحية لجميع الرسومات',
    fileUrl: 'https://example.com/diagrams.png',
    file: CourseAttachment(
      name: 'diagrams.png',
      url: 'https://example.com/diagrams.png',
      mimeType: 'image/png',
      extension: 'png',
      size: 1024 * 1024 * 3,
    ),
  ),
];

Widget createTestWidget({required Size surfaceSize}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, _) => const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CourseResourcesScreen(course: dummyCourse),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    if (sl.isRegistered<CourseResourcesCubit>()) {
      sl.unregister<CourseResourcesCubit>();
    }
    if (sl.isRegistered<DownloadResourceCubit>()) {
      sl.unregister<DownloadResourceCubit>();
    }
    sl.registerFactory<CourseResourcesCubit>(() => FakeCourseResourcesCubit());
    sl.registerFactory<DownloadResourceCubit>(() => FakeDownloadResourceCubit());
  });

  tearDown(() {
    if (sl.isRegistered<CourseResourcesCubit>()) {
      sl.unregister<CourseResourcesCubit>();
    }
    if (sl.isRegistered<DownloadResourceCubit>()) {
      sl.unregister<DownloadResourceCubit>();
    }
  });

  group('CourseResourcesScreen Responsive Layout Tests', () {
    testWidgets('Mobile Portrait (412x915) displays mobile AppBar and body', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(412, 915)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CourseDetailAppBar), findsOneWidget);
      expect(find.byType(CourseResourcesScreenBody), findsOneWidget);
      expect(find.byType(CourseResourcesTabletLandscape), findsNothing);
    });

    testWidgets('Mobile Landscape (844x390) maintains mobile layout', (tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(844, 390)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CourseDetailAppBar), findsOneWidget);
      expect(find.byType(CourseResourcesScreenBody), findsOneWidget);
      expect(find.byType(CourseResourcesTabletLandscape), findsNothing);
    });

    testWidgets('Small Tablet Portrait (768x1024) renders dedicated tablet layout without overflow', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(768, 1024)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CourseResourcesTabletLandscape), findsOneWidget);
      expect(find.byType(CourseDetailAppBar), findsNothing);
      expect(find.text('لا توجد ملازم حالياً'), findsOneWidget);
      expect(find.text('موارد المقرر'), findsOneWidget);
      expect(find.text('الملفات التعليمية'), findsOneWidget);
    });

    testWidgets('7-inch WSVGA Small Tablet Portrait (600x1024) renders tablet layout with 0 overflow', (tester) async {
      tester.view.physicalSize = const Size(600, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(600, 1024)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CourseResourcesTabletLandscape), findsOneWidget);
      expect(find.text('لا توجد ملازم حالياً'), findsOneWidget);
    });

    testWidgets('7-inch WSVGA Small Tablet Landscape (1024x600) renders tablet layout without cutoff or overflow', (tester) async {
      tester.view.physicalSize = const Size(1024, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(1024, 600)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CourseResourcesTabletLandscape), findsOneWidget);
      expect(find.text('لا توجد ملازم حالياً'), findsOneWidget);
      expect(find.text('0 ملفات'), findsOneWidget);
    });

    testWidgets('Large Tablet Landscape (1280x800) renders centered tablet empty state without overflow', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(1280, 800)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CourseResourcesTabletLandscape), findsOneWidget);
      expect(find.text('لا توجد ملازم حالياً'), findsOneWidget);
    });

    testWidgets('Small Tablet Landscape with resources: renders 2 columns of cards', (tester) async {
      sl.unregister<CourseResourcesCubit>();
      sl.registerFactory<CourseResourcesCubit>(() => FakeCourseResourcesCubit(initialResources: dummyResources));

      tester.view.physicalSize = const Size(1024, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(1024, 600)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CourseTabletResourceCard), findsNWidgets(3));
      expect(find.text('ملزمة مراجعة ليلة الامتحان'), findsOneWidget);
      expect(find.text('ملخص الباب الأول والثاني'), findsOneWidget);
      expect(find.text('خرائط ذهنية لمنهج الأحياء'), findsOneWidget);
    });

    testWidgets('Large Tablet Landscape with resources: renders 3 columns of cards with 0 overflow', (tester) async {
      sl.unregister<CourseResourcesCubit>();
      sl.registerFactory<CourseResourcesCubit>(() => FakeCourseResourcesCubit(initialResources: dummyResources));

      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(1280, 800)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CourseTabletResourceCard), findsNWidgets(3));
      expect(find.text('3 ملفات'), findsOneWidget);
      expect(find.text('ملزمة مراجعة ليلة الامتحان'), findsOneWidget);
    });
  });
}

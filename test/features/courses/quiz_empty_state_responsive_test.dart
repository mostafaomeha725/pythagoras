import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/features/courses/presentation/widgets/quizzes/quiz_empty_state.dart';

Widget createQuizEmptyStateTestApp({required Size surfaceSize}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, _) => const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 60), // Simulating app bar / timer header
                  Expanded(child: QuizEmptyState()),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('QuizEmptyState Responsive Tests', () {
    testWidgets(
      '7-inch WSVGA Small Tablet Landscape (1024x600): renders without overflow and displays tablet layout',
      (tester) async {
        tester.view.physicalSize = const Size(1024, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createQuizEmptyStateTestApp(surfaceSize: const Size(1024, 600)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('لا توجد أسئلة'), findsOneWidget);
        expect(
          find.text('هذا الامتحان لا يحتوي على أي أسئلة حالياً'),
          findsOneWidget,
        );
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      },
    );

    testWidgets(
      '7-inch WSVGA Small Tablet Portrait (600x1024): renders without overflow and displays tablet layout',
      (tester) async {
        tester.view.physicalSize = const Size(600, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createQuizEmptyStateTestApp(surfaceSize: const Size(600, 1024)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('لا توجد أسئلة'), findsOneWidget);
        expect(
          find.text('هذا الامتحان لا يحتوي على أي أسئلة حالياً'),
          findsOneWidget,
        );
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      },
    );

    testWidgets(
      'Mobile Portrait (390x844): renders without overflow and preserves mobile layout',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createQuizEmptyStateTestApp(surfaceSize: const Size(390, 844)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('لا توجد أسئلة'), findsOneWidget);
        expect(
          find.text('هذا الامتحان لا يحتوي على أي أسئلة حالياً'),
          findsOneWidget,
        );
        // Mobile does not use SingleChildScrollView in the empty state
        expect(find.byType(SingleChildScrollView), findsNothing);
      },
    );

    testWidgets(
      'Large Tablet Landscape (1280x800): renders without overflow and displays tablet layout',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createQuizEmptyStateTestApp(surfaceSize: const Size(1280, 800)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('لا توجد أسئلة'), findsOneWidget);
        expect(
          find.text('هذا الامتحان لا يحتوي على أي أسئلة حالياً'),
          findsOneWidget,
        );
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      },
    );
  });
}

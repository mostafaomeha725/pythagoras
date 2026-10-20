import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/courses_tablet_error_widget.dart';

Widget buildTestWidget({required Widget child, required Size surfaceSize}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, _) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
}

void main() {
  group('CoursesTabletErrorWidget Tests', () {
    testWidgets(
      'renders balanced tablet error state with 0 overflow and clickable retry button',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        bool retried = false;

        await tester.pumpWidget(
          buildTestWidget(
            surfaceSize: const Size(1280, 800),
            child: CoursesTabletErrorWidget(
              message: 'لا يوجد اتصال بالإنترنت',
              onRetry: () => retried = true,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify elements
        expect(find.text('لا يوجد اتصال بالإنترنت'), findsOneWidget);
        expect(
          find.text(
            'يرجى التحقق من اتصالك بشبكة الواي فاي أو بيانات الهاتف ثم المحاولة مرة أخرى.',
          ),
          findsOneWidget,
        );
        expect(find.text('إعادة المحاولة'), findsOneWidget);
        expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

        // Verify button tap
        await tester.tap(find.text('إعادة المحاولة'));
        await tester.pump();
        expect(retried, isTrue);

        // Verify content column fits within compact height (well under 350px)
        final columnFinder = find.descendant(
          of: find.byType(CoursesTabletErrorWidget),
          matching: find.byType(Column),
        );
        final columnSize = tester.getSize(columnFinder);
        expect(columnSize.height, lessThan(350.0));
      },
    );

    testWidgets(
      'renders without overflow on constrained tablet screen (900x600)',
      (tester) async {
        tester.view.physicalSize = const Size(900, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestWidget(
            surfaceSize: const Size(900, 600),
            child: CoursesTabletErrorWidget(
              message: 'لا يوجد اتصال بالإنترنت',
              onRetry: () {},
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('لا يوجد اتصال بالإنترنت'), findsOneWidget);
        expect(find.text('إعادة المحاولة'), findsOneWidget);
      },
    );
  });
}

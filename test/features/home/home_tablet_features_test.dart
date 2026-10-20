import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/features/home/widgets/home_tablet_features.dart';

Widget buildTestWidget(Widget child, {required Size surfaceSize}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, _) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'HomeTabletFeatures wraps content snugly without excessive height',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(
          const HomeTabletFeatures(),
          surfaceSize: const Size(1280, 800),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('مميزات التعلم الذكي'), findsOneWidget);
      expect(find.text('الدفع حسب الفصل'), findsOneWidget);
      expect(find.text('واجبات تفاعلية'), findsOneWidget);
      expect(find.text('اختبارات وتقييم ذاتي'), findsOneWidget);

      // Each feature card Container size check
      final rowFinder = find.byType(IntrinsicHeight);
      expect(rowFinder, findsOneWidget);
      final rowSize = tester.getSize(rowFinder);
      // Height should be compact around ~80-100px and definitely less than the old 140px minHeight
      expect(rowSize.height, lessThan(125.0));
    },
  );
}

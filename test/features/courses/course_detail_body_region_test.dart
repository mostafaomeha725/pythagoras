import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_screen_body.dart';

void main() {
  const sizes = [Size(390, 844), Size(320, 568)];
  const scenarios = [
    (
      name: 'Apple purchase, Restore, and request',
      footerChildren: <double>[48, 8, 42, 8, 52],
    ),
    (
      name: 'Restore with pending request status',
      footerChildren: <double>[42, 16, 52],
    ),
    (
      name: 'Restore with enrolled course action',
      footerChildren: <double>[42, 16, 52],
    ),
    (name: 'request action only', footerChildren: <double>[16, 52]),
  ];

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final scenario in scenarios) {
      testWidgets(
        '$platform ${scenario.name} avoids layout gaps and overflow',
        (tester) async {
          for (final size in sizes) {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = size;
            final safeBottom = platform == TargetPlatform.iOS ? 34.0 : 0.0;
            final footerHeight =
                scenario.footerChildren.fold<double>(0, (sum, h) => sum + h) +
                24 +
                safeBottom;
            final contentHeight = size.height < 600 ? 700.0 : 120.0;

            await tester.pumpWidget(
              MaterialApp(
                theme: ThemeData(platform: platform),
                home: Builder(
                  builder: (context) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      padding: EdgeInsets.only(bottom: safeBottom),
                      viewPadding: EdgeInsets.only(bottom: safeBottom),
                    ),
                    child: Scaffold(
                      body: Column(
                        children: [
                          CourseDetailBodyRegion(
                            child: SingleChildScrollView(
                              key: const ValueKey('detail-content'),
                              child: SizedBox(height: contentHeight),
                            ),
                          ),
                          Padding(
                            key: const ValueKey('detail-footer'),
                            padding: const EdgeInsets.only(bottom: 24),
                            child: SafeArea(
                              top: false,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (
                                    var i = 0;
                                    i < scenario.footerChildren.length;
                                    i++
                                  )
                                    SizedBox(
                                      key: ValueKey('footer-child-$i'),
                                      height: scenario.footerChildren[i],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );

            final contentRect = tester.getRect(
              find.byKey(const ValueKey('detail-content')),
            );
            final footerRect = tester.getRect(
              find.byKey(const ValueKey('detail-footer')),
            );
            final lastButtonRect = tester.getRect(
              find.byKey(
                ValueKey('footer-child-${scenario.footerChildren.length - 1}'),
              ),
            );

            if (platform == TargetPlatform.iOS) {
              expect(footerRect.top, contentRect.bottom);
              expect(
                lastButtonRect.bottom,
                lessThanOrEqualTo(size.height - safeBottom - 24),
              );
              expect(footerRect.bottom, lessThanOrEqualTo(size.height));
              if (contentHeight < size.height - footerHeight) {
                expect(contentRect.height, contentHeight);
              }
            } else {
              expect(footerRect.bottom, size.height);
              expect(contentRect.height, size.height - footerHeight);
            }
            if (contentHeight > contentRect.height) {
              await tester.drag(
                find.byKey(const ValueKey('detail-content')),
                const Offset(0, -100),
              );
              await tester.pumpAndSettle();
            }
            expect(tester.takeException(), isNull);
          }

          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        },
      );
    }
  }
}

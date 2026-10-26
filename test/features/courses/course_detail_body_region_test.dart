import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/features/courses/domain/entities/course_chapter.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_chapter_tile.dart';
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
  const shortCourse = CourseDetail(
    id: 21,
    title: 'Course 21',
    description: 'Short description',
    level: 'Secondary',
    className: 'Class 1',
    isEnrolled: false,
    price: '100',
    finalPrice: 100,
    currencyLabel: 'EGP',
    studentsCount: 0,
    isSaved: false,
    requestStatus: 'not_requested',
    rating: 0,
    category: 'Math',
    chapters: [
      CourseChapter(
        id: 1,
        title: 'Chapter 1',
        order: 1,
        price: '0',
        currency: 'EGP',
        currencyLabel: 'EGP',
      ),
    ],
  );

  testWidgets('actual short course content keeps iOS footer close', (
    tester,
  ) async {
    for (final size in sizes) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      const safeBottom = 34.0;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.only(bottom: safeBottom),
                viewPadding: const EdgeInsets.only(bottom: safeBottom),
              ),
              child: Scaffold(
                body: Column(
                  children: [
                    CourseDetailBodyRegion(
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        child: CourseDetailScreenBody(
                          key: const ValueKey('actual-course-body'),
                          course: shortCourse,
                        ),
                      ),
                    ),
                    const Padding(
                      key: ValueKey('actual-footer'),
                      padding: EdgeInsets.only(bottom: 24),
                      child: SafeArea(top: false, child: SizedBox(height: 150)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final chapterRect = tester.getRect(find.byType(CourseChapterTile));
      final footerRect = tester.getRect(
        find.byKey(const ValueKey('actual-footer')),
      );
      final gap = footerRect.top - chapterRect.bottom;

      expect(gap, lessThanOrEqualTo(8), reason: 'gap was $gap at $size');
      expect(
        tester.getRect(find.byKey(const ValueKey('actual-footer'))).bottom,
        lessThanOrEqualTo(size.height),
      );
      expect(tester.takeException(), isNull);
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

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

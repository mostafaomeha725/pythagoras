import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_source_sheet.dart';

Widget createTestApp({
  required Size surfaceSize,
  required VoidCallback onPickGallery,
  required VoidCallback onPickFileSystem,
}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, _) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    SubmitAssignmentSourceSheet.show(
                      ctx,
                      onPickGallery: onPickGallery,
                      onPickFileSystem: onPickFileSystem,
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('SubmitAssignmentSourceSheet Responsive Layout Tests', () {
    testWidgets(
      'Mobile Portrait (390x844): renders mobile layout with ListTile',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        bool galleryCalled = false;
        bool filesCalled = false;

        await tester.pumpWidget(
          createTestApp(
            surfaceSize: const Size(390, 844),
            onPickGallery: () => galleryCalled = true,
            onPickFileSystem: () => filesCalled = true,
          ),
        );
        await tester.pumpAndSettle();

        // Tap open sheet
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // Verify mobile elements (ListTile is used on mobile)
        expect(find.byType(ListTile), findsNWidgets(2));
        expect(find.text('اختر طريقة الرفع'), findsOneWidget);
        expect(find.text('معرض الصور (Photos)'), findsOneWidget);
        expect(find.text('الملفات والمستندات (Files)'), findsOneWidget);

        // Tap gallery option
        await tester.tap(find.text('معرض الصور (Photos)'));
        await tester.pumpAndSettle();

        expect(galleryCalled, isTrue);
        expect(filesCalled, isFalse);
      },
    );

    testWidgets(
      'Mobile Landscape (844x390): maintains mobile layout without tablet constraints',
      (tester) async {
        tester.view.physicalSize = const Size(844, 390);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestApp(
            surfaceSize: const Size(844, 390),
            onPickGallery: () {},
            onPickFileSystem: () {},
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // Mobile layout still used
        expect(find.byType(ListTile), findsNWidgets(2));
        expect(find.text('اختر طريقة الرفع'), findsOneWidget);
      },
    );

    testWidgets(
      'Small Tablet Portrait (768x1024): renders dedicated tablet layout with maxWidth 520, full titles and zero clipping',
      (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        bool galleryCalled = false;
        bool filesCalled = false;

        await tester.pumpWidget(
          createTestApp(
            surfaceSize: const Size(768, 1024),
            onPickGallery: () => galleryCalled = true,
            onPickFileSystem: () => filesCalled = true,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // On tablet, custom responsive rows are used instead of ListTile
        expect(find.byType(ListTile), findsNothing);

        // Verify title & all option titles are fully visible
        expect(find.text('اختر طريقة الرفع'), findsOneWidget);
        expect(find.text('معرض الصور (Photos)'), findsOneWidget);
        expect(find.text('الملفات والمستندات (Files)'), findsOneWidget);
        expect(find.text('اختيار صورة من ألبوم الصور مباشرة'), findsOneWidget);
        expect(
          find.text('تصفح المستندات و iCloud Drive وملفات الجهاز'),
          findsOneWidget,
        );

        // Verify no text clipping (didExceedMaxLines == false)
        final galleryTitleFinder = find.text('معرض الصور (Photos)');
        final galleryTitleParagraph = tester.renderObject<RenderParagraph>(
          galleryTitleFinder,
        );
        expect(galleryTitleParagraph.didExceedMaxLines, isFalse);

        final filesTitleFinder = find.text('الملفات والمستندات (Files)');
        final filesTitleParagraph = tester.renderObject<RenderParagraph>(
          filesTitleFinder,
        );
        expect(filesTitleParagraph.didExceedMaxLines, isFalse);

        final filesSubtitleFinder = find.text(
          'تصفح المستندات و iCloud Drive وملفات الجهاز',
        );
        final filesSubtitleParagraph = tester.renderObject<RenderParagraph>(
          filesSubtitleFinder,
        );
        expect(filesSubtitleParagraph.didExceedMaxLines, isFalse);

        // Tap Files option
        await tester.tap(filesTitleFinder);
        await tester.pumpAndSettle();

        expect(filesCalled, isTrue);
        expect(galleryCalled, isFalse);
      },
    );

    testWidgets(
      'Small Tablet Landscape (1024x768): renders tablet layout with maxWidth 520 and full text',
      (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestApp(
            surfaceSize: const Size(1024, 768),
            onPickGallery: () {},
            onPickFileSystem: () {},
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        expect(find.byType(ListTile), findsNothing);
        expect(find.text('اختر طريقة الرفع'), findsOneWidget);
        expect(find.text('معرض الصور (Photos)'), findsOneWidget);
        expect(find.text('الملفات والمستندات (Files)'), findsOneWidget);

        final filesTitleFinder = find.text('الملفات والمستندات (Files)');
        final filesTitleParagraph = tester.renderObject<RenderParagraph>(
          filesTitleFinder,
        );
        expect(filesTitleParagraph.didExceedMaxLines, isFalse);
      },
    );

    testWidgets(
      'Large Tablet Landscape (1280x800): renders centered tablet layout without stretching',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestApp(
            surfaceSize: const Size(1280, 800),
            onPickGallery: () {},
            onPickFileSystem: () {},
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        expect(find.byType(ListTile), findsNothing);
        expect(find.text('اختر طريقة الرفع'), findsOneWidget);
        expect(find.text('معرض الصور (Photos)'), findsOneWidget);
        expect(find.text('الملفات والمستندات (Files)'), findsOneWidget);

        // Verify sheet width is bounded by maxWidth 520
        final sheetFinder = find.byType(SubmitAssignmentSourceSheet);
        final sheetSize = tester.getSize(sheetFinder);
        expect(sheetSize.width, lessThanOrEqualTo(520.0));
      },
    );
  });
}

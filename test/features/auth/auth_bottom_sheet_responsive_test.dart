import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/features/auth/presentation/widgets/auth_bottom_sheet.dart';
import 'package:pythagoras/features/auth/presentation/widgets/auth_tablet_bottom_sheet.dart';
import 'package:pythagoras/features/auth/presentation/widgets/auth_tablet_bottom_sheet_actions.dart';

Widget buildTestSheet({
  required Size surfaceSize,
  required Widget child,
  EdgeInsets viewInsets = EdgeInsets.zero,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: surfaceSize,
      viewInsets: viewInsets,
    ),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
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
  group('AuthBottomSheet - Responsive Layout Isolation Tests', () {
    testWidgets(
      'Tablet Landscape (1280x800): renders AuthTabletBottomSheet with max width 450 and actions',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          buildTestSheet(
            surfaceSize: const Size(1280, 800),
            child: const AuthBottomSheet(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AuthTabletBottomSheet), findsOneWidget);
        expect(find.byType(AuthTabletBottomSheetActions), findsOneWidget);
        expect(find.text('يجب تسجيل الدخول أولًا'), findsOneWidget);
        expect(find.text('تسجيل الدخول'), findsOneWidget);
        expect(find.text('إلغاء'), findsOneWidget);

        // Verify constrained width
        final constrainedBoxFinder = find.descendant(
          of: find.byType(AuthTabletBottomSheet),
          matching: find.byType(ConstrainedBox),
        );
        final constrainedBox =
            tester.widget<ConstrainedBox>(constrainedBoxFinder.first);
        expect(constrainedBox.constraints.maxWidth, 450);
      },
    );

    testWidgets(
      'Mobile Portrait (412x915): preserves original mobile layout, NOT tablet sheet',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(412, 915));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          buildTestSheet(
            surfaceSize: const Size(412, 915),
            child: const AuthBottomSheet(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AuthTabletBottomSheet), findsNothing);
        expect(find.byType(AuthTabletBottomSheetActions), findsNothing);
        expect(find.text('يجب تسجيل الدخول أولًا'), findsOneWidget);
        expect(find.text('تسجيل الدخول'), findsOneWidget);
        expect(find.text('إلغاء'), findsOneWidget);
      },
    );

    testWidgets(
      'Tablet Portrait (800x1280): preserves original layout, NOT tablet landscape sheet',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1280));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          buildTestSheet(
            surfaceSize: const Size(800, 1280),
            child: const AuthBottomSheet(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AuthTabletBottomSheet), findsNothing);
        expect(find.byType(AuthTabletBottomSheetActions), findsNothing);
      },
    );

    testWidgets(
      'Mobile Landscape (844x390): preserves original layout, NOT tablet sheet',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(844, 390));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          buildTestSheet(
            surfaceSize: const Size(844, 390),
            child: const SingleChildScrollView(child: AuthBottomSheet()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AuthTabletBottomSheet), findsNothing);
        expect(find.byType(AuthTabletBottomSheetActions), findsNothing);
      },
    );
  });

  group('AuthTabletBottomSheet - Components & Interaction Tests', () {
    testWidgets(
      'Tablet Landscape with keyboard open does not overflow',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          buildTestSheet(
            surfaceSize: const Size(1280, 800),
            viewInsets: const EdgeInsets.only(bottom: 260),
            child: const AuthTabletBottomSheet(),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AuthTabletBottomSheetActions), findsOneWidget);
        expect(find.text('تسجيل الدخول'), findsOneWidget);
        expect(find.text('إلغاء'), findsOneWidget);
      },
    );

    testWidgets(
      'Callbacks for onCancel and onLogin are triggered when buttons are tapped',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        bool cancelTapped = false;
        bool loginTapped = false;

        await tester.pumpWidget(
          buildTestSheet(
            surfaceSize: const Size(1280, 800),
            child: AuthTabletBottomSheet(
              onCancel: () => cancelTapped = true,
              onLogin: () async => loginTapped = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Cancel
        final cancelFinder = find.widgetWithText(BounceIt, 'إلغاء');
        expect(cancelFinder, findsOneWidget);
        await tester.tap(cancelFinder);
        await tester.pumpAndSettle();
        expect(cancelTapped, isTrue);

        // Tap Login
        final loginFinder = find.widgetWithText(BounceIt, 'تسجيل الدخول');
        expect(loginFinder, findsOneWidget);
        await tester.tap(loginFinder);
        await tester.pumpAndSettle();
        expect(loginTapped, isTrue);
      },
    );
  });
}

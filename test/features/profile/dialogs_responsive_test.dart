import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/features/profile/presentation/widgets/delete_account_tablet_dialog.dart';
import 'package:pythagoras/features/profile/presentation/widgets/logout_tablet_dialog.dart';

Widget buildTestDialog(Widget child, {required Size surfaceSize}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, _) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    ),
  );
}

void main() {
  group('DeleteAccountTabletDialog Tests', () {
    testWidgets(
      'renders all warning content and action buttons with 0 overflow',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        bool confirmed = false;
        bool cancelled = false;

        await tester.pumpWidget(
          buildTestDialog(
            DeleteAccountTabletDialog(
              isLoading: false,
              onConfirm: () => confirmed = true,
              onCancel: () => cancelled = true,
            ),
            surfaceSize: const Size(1280, 800),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Title & Subtitle
        expect(find.text('حذف الحساب نهائياً'), findsOneWidget);
        expect(
          find.text('هل أنت متأكد من رغبتك في حذف حسابك؟'),
          findsOneWidget,
        );

        // Verify Full Warning Message
        expect(
          find.textContaining('تنبيه: سيؤدي هذا الإجراء إلى مسح كافة بياناتك'),
          findsOneWidget,
        );

        // Verify Buttons
        expect(find.text('إلغاء'), findsOneWidget);
        expect(find.text('تأكيد الحذف'), findsOneWidget);

        // Test Cancel Interaction
        await tester.tap(find.text('إلغاء'));
        await tester.pump();
        expect(cancelled, isTrue);

        // Test Confirm Interaction
        await tester.tap(find.text('تأكيد الحذف'));
        await tester.pump();
        expect(confirmed, isTrue);
      },
    );

    testWidgets(
      'renders without overflow even on constrained height screen (900x600)',
      (tester) async {
        tester.view.physicalSize = const Size(900, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestDialog(
            DeleteAccountTabletDialog(
              isLoading: false,
              onConfirm: () {},
              onCancel: () {},
            ),
            surfaceSize: const Size(900, 600),
          ),
        );
        await tester.pumpAndSettle();

        // Action buttons must be permanently visible and not pushed off
        expect(find.text('إلغاء'), findsOneWidget);
        expect(find.text('تأكيد الحذف'), findsOneWidget);
      },
    );
  });

  group('LogoutTabletDialog Tests', () {
    testWidgets('renders balanced icon, title, subtitle, and action buttons', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool confirmed = false;
      bool cancelled = false;

      await tester.pumpWidget(
        buildTestDialog(
          LogoutTabletDialog(
            isLoading: false,
            onConfirm: () => confirmed = true,
            onCancel: () => cancelled = true,
          ),
          surfaceSize: const Size(1280, 800),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('هل تريد تسجيل الخروج؟'), findsOneWidget);
      expect(find.text('سيتم إنهاء جلستك الحالية سريعا.'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);
      expect(find.text('تسجيل الخروج'), findsOneWidget);

      await tester.tap(find.text('إلغاء'));
      await tester.pump();
      expect(cancelled, isTrue);

      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pump();
      expect(confirmed, isTrue);
    });
  });
}

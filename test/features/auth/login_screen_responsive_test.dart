import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_state.dart';
import 'package:pythagoras/features/auth/presentation/screens/login_screen.dart';
import 'package:pythagoras/features/auth/presentation/widgets/login_form.dart';
import 'package:pythagoras/features/auth/presentation/widgets/login_tablet_landscape.dart';

class FakeLoginCubit extends Cubit<LoginState> implements LoginCubit {
  FakeLoginCubit() : super(LoginInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> login(String phone, String password) async {
    emit(LoginLoading());
    emit(LoginSuccess());
  }
}

Widget createTestWidget({
  required Size surfaceSize,
  EdgeInsets viewInsets = EdgeInsets.zero,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: surfaceSize,
      viewInsets: viewInsets,
    ),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, _) => const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: LoginScreen(),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    if (sl.isRegistered<LoginCubit>()) {
      sl.unregister<LoginCubit>();
    }
    sl.registerFactory<LoginCubit>(() => FakeLoginCubit());
  });

  tearDown(() {
    if (sl.isRegistered<LoginCubit>()) {
      sl.unregister<LoginCubit>();
    }
  });

  group('LoginScreen Responsive & Keyboard Stability Tests', () {
    testWidgets(
      'Mobile Portrait (412x915): renders default layout and stays stable when keyboard opens',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(412, 915)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LoginTabletLandscape), findsNothing);
        expect(find.byKey(const ValueKey('default_login_form')), findsOneWidget);

        // Simulate keyboard opening
        await tester.pumpWidget(
          createTestWidget(
            surfaceSize: const Size(412, 915),
            viewInsets: const EdgeInsets.only(bottom: 300),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LoginTabletLandscape), findsNothing);
        expect(find.byKey(const ValueKey('default_login_form')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Mobile Landscape (844x390): maintains mobile layout without switching to tablet',
      (tester) async {
        tester.view.physicalSize = const Size(844, 390);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(844, 390)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LoginTabletLandscape), findsNothing);
        expect(find.byKey(const ValueKey('default_login_form')), findsOneWidget);

        // Simulate keyboard opening
        await tester.pumpWidget(
          createTestWidget(
            surfaceSize: const Size(844, 390),
            viewInsets: const EdgeInsets.only(bottom: 220),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LoginTabletLandscape), findsNothing);
        expect(find.byKey(const ValueKey('default_login_form')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Small Tablet Portrait (768x1024): does NOT flip to tablet landscape when keyboard opens',
      (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(768, 1024)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LoginTabletLandscape), findsNothing);
        expect(find.byKey(const ValueKey('default_login_form')), findsOneWidget);

        // Simulate keyboard opening with 350px height
        await tester.pumpWidget(
          createTestWidget(
            surfaceSize: const Size(768, 1024),
            viewInsets: const EdgeInsets.only(bottom: 350),
          ),
        );
        await tester.pumpAndSettle();

        // Must remain in default layout, never flipping to tablet landscape
        expect(find.byType(LoginTabletLandscape), findsNothing);
        expect(find.byKey(const ValueKey('default_login_form')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Large Tablet Portrait (1024x1366): does NOT flip to tablet landscape when keyboard opens',
      (tester) async {
        tester.view.physicalSize = const Size(1024, 1366);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(1024, 1366)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LoginTabletLandscape), findsNothing);
        expect(find.byKey(const ValueKey('default_login_form')), findsOneWidget);

        // Keyboard opens, reducing available height (1366 - 450 = 916 < 1024)
        await tester.pumpWidget(
          createTestWidget(
            surfaceSize: const Size(1024, 1366),
            viewInsets: const EdgeInsets.only(bottom: 450),
          ),
        );
        await tester.pumpAndSettle();

        // Must NOT flip to tablet landscape!
        expect(find.byType(LoginTabletLandscape), findsNothing);
        expect(find.byKey(const ValueKey('default_login_form')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Tablet Landscape (1280x800): renders LoginTabletLandscape and preserves focus when keyboard opens',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(1280, 800)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LoginTabletLandscape), findsOneWidget);
        expect(find.byKey(const ValueKey('tablet_login_form')), findsOneWidget);

        // Find Phone field and give it focus
        final phoneFieldFinder = find.byType(TextFormField).first;
        await tester.tap(phoneFieldFinder);
        await tester.pump();

        // Simulate software keyboard opening (e.g. 340px)
        await tester.pumpWidget(
          createTestWidget(
            surfaceSize: const Size(1280, 800),
            viewInsets: const EdgeInsets.only(bottom: 340),
          ),
        );
        await tester.pumpAndSettle();

        // LoginTabletLandscape must REMAIN mounted!
        expect(find.byType(LoginTabletLandscape), findsOneWidget);
        expect(find.byKey(const ValueKey('tablet_login_form')), findsOneWidget);
        expect(find.byType(LoginForm), findsOneWidget);

        // The field must still have focus
        final phoneFieldEditable = tester.widget<EditableText>(
          find.descendant(
            of: phoneFieldFinder,
            matching: find.byType(EditableText),
          ),
        );
        expect(phoneFieldEditable.focusNode.hasFocus, isTrue);

        // Enter text and verify controller updates
        await tester.enterText(phoneFieldFinder, '12345678');
        await tester.pump();
        expect(find.text('12345678'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Tablet Landscape (1024x768): moving focus between fields and toggling password does not lose focus or flip layout',
      (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(
            surfaceSize: const Size(1024, 768),
            viewInsets: const EdgeInsets.only(bottom: 320),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LoginTabletLandscape), findsOneWidget);

        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(2));

        // Focus Phone input
        await tester.tap(textFields.at(0));
        await tester.pump();
        await tester.enterText(textFields.at(0), '98765432');
        await tester.pump();

        // Focus Password input
        await tester.tap(textFields.at(1));
        await tester.pump();
        await tester.enterText(textFields.at(1), 'secret123');
        await tester.pump();

        final passwordEditable = tester.widget<EditableText>(
          find.descendant(
            of: textFields.at(1),
            matching: find.byType(EditableText),
          ),
        );
        expect(passwordEditable.focusNode.hasFocus, isTrue);
        expect(passwordEditable.obscureText, isTrue);

        // Toggle obscure text
        final toggleVisibilityIcon = find.byIcon(Icons.visibility_off_outlined);
        expect(toggleVisibilityIcon, findsOneWidget);
        await tester.tap(toggleVisibilityIcon);
        await tester.pump();

        expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
        expect(find.byType(LoginTabletLandscape), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'WSVGA Small Tablet Landscape (1024x600): layout remains stable without overflow when keyboard is open',
      (tester) async {
        tester.view.physicalSize = const Size(1024, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(
            surfaceSize: const Size(1024, 600),
            viewInsets: const EdgeInsets.only(bottom: 280),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LoginTabletLandscape), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}

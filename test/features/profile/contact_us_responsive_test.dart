import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/profile/presentation/cubit/contact_us/contact_us_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/contact_us/contact_us_state.dart';
import 'package:pythagoras/features/profile/presentation/screens/contact_us_screen.dart';
import 'package:pythagoras/features/profile/presentation/widgets/contact_us_tablet_form_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/contact_us_tablet_info_panel.dart';
import 'package:pythagoras/features/profile/presentation/widgets/contact_us_tablet_landscape.dart';
import 'package:pythagoras/features/profile/presentation/widgets/contact_us_tablet_top_bar.dart';

class FakeContactUsCubit extends Cubit<ContactUsState>
    implements ContactUsCubit {
  String? submittedName;
  String? submittedEmail;
  String? submittedMessage;

  FakeContactUsCubit() : super(ContactUsInitial());

  @override
  Future<void> submit({
    required String name,
    required String email,
    required String message,
  }) async {
    submittedName = name;
    submittedEmail = email;
    submittedMessage = message;
    emit(ContactUsSuccess('تم إرسال رسالتك بنجاح'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget createTestWidget({required Size surfaceSize}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, child) => MaterialApp(
        builder: EasyLoading.init(),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: ContactUsScreen(),
        ),
      ),
    ),
  );
}

void main() {
  late FakeContactUsCubit fakeCubit;

  setUp(() {
    fakeCubit = FakeContactUsCubit();
    if (sl.isRegistered<ContactUsCubit>()) {
      sl.unregister<ContactUsCubit>();
    }
    sl.registerFactory<ContactUsCubit>(() => fakeCubit);
  });

  group('ContactUsScreen Responsive Layout Tests', () {
    testWidgets('Mobile Portrait displays standard mobile AppBar and body', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestWidget(surfaceSize: const Size(390, 844)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CourseDetailAppBar), findsOneWidget);
      expect(find.byType(ContactUsTabletLandscape), findsNothing);
      expect(find.byType(ContactUsTabletTopBar), findsNothing);
    });

    testWidgets(
      'Mobile Landscape does NOT trigger tablet layout (height < 600)',
      (tester) async {
        tester.view.physicalSize = const Size(844, 390);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(844, 390)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CourseDetailAppBar), findsOneWidget);
        expect(find.byType(ContactUsTabletLandscape), findsNothing);
      },
    );

    testWidgets(
      'Small Tablet Portrait (768x1024) renders tablet layout with TopBar and components',
      (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(768, 1024)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CourseDetailAppBar), findsNothing);
        expect(find.byType(ContactUsTabletLandscape), findsOneWidget);
        expect(find.byType(ContactUsTabletTopBar), findsOneWidget);
        expect(find.byType(ContactUsTabletInfoPanel), findsOneWidget);
        expect(find.byType(ContactUsTabletFormCard), findsOneWidget);
      },
    );

    testWidgets(
      'Small Tablet Landscape (1024x768) renders tablet layout with TopBar and components',
      (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(1024, 768)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CourseDetailAppBar), findsNothing);
        expect(find.byType(ContactUsTabletLandscape), findsOneWidget);
        expect(find.byType(ContactUsTabletTopBar), findsOneWidget);
        expect(find.byType(ContactUsTabletInfoPanel), findsOneWidget);
        expect(find.byType(ContactUsTabletFormCard), findsOneWidget);
      },
    );

    testWidgets(
      'Tablet Landscape renders dedicated 2-column layout with all contact data & form',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(1280, 800)),
        );
        await tester.pumpAndSettle();

        // Mobile app bar must be omitted on tablet landscape
        expect(find.byType(CourseDetailAppBar), findsNothing);

        // Tablet landscape components must be present
        expect(find.byType(ContactUsTabletLandscape), findsOneWidget);
        expect(find.byType(ContactUsTabletTopBar), findsOneWidget);
        expect(find.byType(ContactUsTabletInfoPanel), findsOneWidget);
        expect(find.byType(ContactUsTabletFormCard), findsOneWidget);

        // Verify preserved contact details
        expect(find.text('65608054'), findsOneWidget);
        expect(find.text('info@neudrosi-pythagoras.com'), findsOneWidget);
        expect(
          find.text(
            'هل لديك سؤال، أو تحتاج إلى مساعدة، أو تريد فقط أن تقول مرحباً؟ فريق الدعم لدينا هنا لمساعدتك.',
          ),
          findsOneWidget,
        );

        // Verify form fields and action button
        expect(find.text('الاسم'), findsOneWidget);
        expect(find.text('البريد الإلكتروني'), findsNWidgets(2));
        expect(find.text('الرسالة'), findsOneWidget);
        expect(find.text('إرسال الرسالة'), findsOneWidget);

        // Verify submit button is fully visible within 800px viewport without scrolling
        final submitButtonRect = tester.getRect(find.text('إرسال الرسالة'));
        expect(submitButtonRect.bottom, lessThan(800.0));

        // Verify email is not truncated
        final emailFinder = find.text('info@neudrosi-pythagoras.com');
        final emailParagraph = tester.renderObject<RenderParagraph>(
          emailFinder,
        );
        expect(emailParagraph.didExceedMaxLines, isFalse);

        // Verify text field hint font size is fixed and crisp (13px, not 43px)
        final nameTextField = tester.widget<TextField>(
          find.byType(TextField).at(0),
        );
        expect(nameTextField.decoration?.hintStyle?.fontSize, equals(13.0));
        expect(nameTextField.style?.fontSize, equals(13.5));

        // Fill in form and submit
        await tester.enterText(find.byType(TextFormField).at(0), 'أحمد علي');
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'ahmed@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'استفسار بخصوص اشتراك كورس الرياضيات',
        );

        await tester.tap(find.text('إرسال الرسالة'));
        await tester.pumpAndSettle();

        expect(fakeCubit.submittedName, equals('أحمد علي'));
        expect(fakeCubit.submittedEmail, equals('ahmed@example.com'));
        expect(
          fakeCubit.submittedMessage,
          equals('استفسار بخصوص اشتراك كورس الرياضيات'),
        );
      },
    );
  });
}

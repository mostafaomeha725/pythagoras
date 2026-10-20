import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/profile/presentation/screens/privacy_policy_screen.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_sections_data.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_tablet_contact_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_tablet_header_banner.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_tablet_landscape.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_tablet_section_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_tablet_sidebar.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_tablet_top_bar.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_tablet_web_card.dart';

Widget createTestWidget({required Size surfaceSize}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, child) => const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: PrivacyPolicyScreen(),
        ),
      ),
    ),
  );
}

void main() {
  group('PrivacyPolicyScreen Responsive Layout Tests', () {
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
      expect(find.byType(PrivacyPolicyTabletLandscape), findsNothing);
      expect(find.byType(PrivacyPolicyTabletTopBar), findsNothing);
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
        expect(find.byType(PrivacyPolicyTabletLandscape), findsNothing);
      },
    );

    testWidgets(
      'Tablet Portrait renders tablet layout with top bar and sections',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1280);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(800, 1280)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CourseDetailAppBar), findsNothing);
        expect(find.byType(PrivacyPolicyTabletLandscape), findsOneWidget);
        expect(find.byType(PrivacyPolicyTabletTopBar), findsOneWidget);
      },
    );

    testWidgets(
      'Tablet Landscape renders dedicated Tablet Layout with top bar and cards',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(1280, 800)),
        );
        await tester.pumpAndSettle();

        // Mobile app bar should be omitted on Tablet Landscape
        expect(find.byType(CourseDetailAppBar), findsNothing);

        // Dedicated tablet landscape widgets must be rendered
        expect(find.byType(PrivacyPolicyTabletLandscape), findsOneWidget);
        expect(find.byType(PrivacyPolicyTabletTopBar), findsOneWidget);
        expect(find.byType(PrivacyPolicyTabletSidebar), findsOneWidget);
        expect(find.byType(PrivacyPolicyTabletHeaderBanner), findsOneWidget);
        expect(find.byType(PrivacyPolicyTabletWebCard), findsOneWidget);
        expect(find.byType(PrivacyPolicyTabletContactCard), findsOneWidget);

        // Verify all 9 sections are rendered
        expect(
          find.byType(PrivacyPolicyTabletSectionCard),
          findsNWidgets(PrivacyPolicySectionsData.sections.length),
        );

        // Verify presence of specific key legal sections
        expect(find.text('١. تفسيرات وتعريفات أساسية'), findsOneWidget);
        expect(
          find.text('٥. مدة الاحتفاظ بالبيانات وحذف الحساب'),
          findsOneWidget,
        );
        expect(find.text('٩. التحديثات والتعديلات'), findsOneWidget);

        // Verify the date badge is shrink-wrapped to fit the date content (not stretched to card width)
        final bannerSize =
            tester.getSize(find.byType(PrivacyPolicyTabletHeaderBanner));
        final dateFinder = find.text('آخر تحديث: ١٤ أكتوبر ٢٠٢٦');
        expect(dateFinder, findsOneWidget);
        final badgeFinder =
            find.ancestor(of: dateFinder, matching: find.byType(Container)).first;
        final badgeSize = tester.getSize(badgeFinder);
        expect(badgeSize.width, lessThan(bannerSize.width * 0.85));
      },
    );
  });
}

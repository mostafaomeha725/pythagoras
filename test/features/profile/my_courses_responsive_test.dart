import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/features/profile/presentation/cubit/my_courses/my_courses_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/my_courses/my_courses_state.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_course_tablet_shimmer_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_courses_screen_body.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_courses_shimmer.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_courses_tablet_landscape.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_courses_tablet_shimmer.dart';
import 'package:pythagoras/features/profile/presentation/widgets/my_courses_tablet_top_bar.dart';

class FakeMyCoursesCubit extends Cubit<MyCoursesState>
    implements MyCoursesCubit {
  FakeMyCoursesCubit([MyCoursesState? initialState])
      : super(initialState ?? MyCoursesLoading());

  @override
  Future<void> fetchMyCourses() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget createTestWidget({
  required Size surfaceSize,
  required MyCoursesCubit cubit,
}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, child) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: BlocProvider<MyCoursesCubit>.value(
              value: cubit,
              child: const MyCoursesScreenBody(),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('MyCourses Responsive Layout & Shimmer Tests', () {
    testWidgets(
      'Tablet Landscape (1280x800) in Loading state renders MyCoursesTabletShimmer with TopBar and grid cards',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakeCubit = FakeMyCoursesCubit(MyCoursesLoading());

        await tester.pumpWidget(
          createTestWidget(
            surfaceSize: const Size(1280, 800),
            cubit: fakeCubit,
          ),
        );
        await tester.pump();

        expect(find.byType(MyCoursesTabletLandscape), findsOneWidget);
        expect(find.byType(MyCoursesTabletShimmer), findsOneWidget);
        expect(find.byType(MyCoursesTabletTopBar), findsOneWidget);
        expect(find.byType(MyCourseTabletShimmerCard), findsWidgets);
        expect(find.byType(MyCoursesShimmer), findsNothing);
      },
    );

    testWidgets(
      'Mobile Portrait (412x915) in Loading state preserves mobile MyCoursesShimmer, NOT tablet shimmer',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(412, 915));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakeCubit = FakeMyCoursesCubit(MyCoursesLoading());

        await tester.pumpWidget(
          createTestWidget(
            surfaceSize: const Size(412, 915),
            cubit: fakeCubit,
          ),
        );
        await tester.pump();

        expect(find.byType(MyCoursesShimmer), findsOneWidget);
        expect(find.byType(MyCoursesTabletLandscape), findsNothing);
        expect(find.byType(MyCoursesTabletShimmer), findsNothing);
      },
    );

    testWidgets(
      'Tablet Portrait (800x1280) in Loading state renders tablet MyCoursesTabletShimmer and landscape layout',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1280));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakeCubit = FakeMyCoursesCubit(MyCoursesLoading());

        await tester.pumpWidget(
          createTestWidget(
            surfaceSize: const Size(800, 1280),
            cubit: fakeCubit,
          ),
        );
        await tester.pump();

        expect(find.byType(MyCoursesTabletLandscape), findsOneWidget);
        expect(find.byType(MyCoursesTabletShimmer), findsOneWidget);
        expect(find.byType(MyCoursesShimmer), findsNothing);
      },
    );

    testWidgets(
      'Mobile Landscape (844x390) in Loading state preserves mobile MyCoursesShimmer, NOT tablet shimmer',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(844, 390));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakeCubit = FakeMyCoursesCubit(MyCoursesLoading());

        await tester.pumpWidget(
          createTestWidget(
            surfaceSize: const Size(844, 390),
            cubit: fakeCubit,
          ),
        );
        await tester.pump();

        expect(find.byType(MyCoursesShimmer), findsOneWidget);
        expect(find.byType(MyCoursesTabletLandscape), findsNothing);
        expect(find.byType(MyCoursesTabletShimmer), findsNothing);
      },
    );
  });
}

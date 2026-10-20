import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_card/course_shimmer_list.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/course_tablet_grid.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/course_tablet_shimmer_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/courses_tablet_landscape.dart';
import 'package:pythagoras/features/courses/presentation/widgets/courses_list/courses_tablet_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_recorded_lessons_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/lessons/course_recorded_lessons_tablet_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/course_online_lessons_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/course_online_lessons_tablet_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/online_lessons/course_tablet_online_lesson_shimmer_card.dart';

class FakeClassesCubit extends Cubit<ClassesState> implements ClassesCubit {
  FakeClassesCubit()
      : super(
          const ClassesLoaded(
            classes: [
              StudentClass(id: 0, name: 'الكل'),
              StudentClass(id: 1, name: 'الصف العاشر'),
            ],
            selectedClass: StudentClass(id: 0, name: 'الكل'),
          ),
        );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCoursesListCubit extends Cubit<CoursesListState>
    implements CoursesListCubit {
  FakeCoursesListCubit({bool loading = false})
      : super(loading ? CoursesListLoading() : CoursesListLoaded(const []));
  @override
  Future<void> fetchCourses() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget buildTestWidget({
  required Size surfaceSize,
  required Widget child,
}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
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
  group('Course Detail Shimmer Tests', () {
    testWidgets(
      'CourseDetailTabletShimmer renders fixed top bar, 2-column skeleton, and bottom action button',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          buildTestWidget(
            surfaceSize: const Size(1280, 800),
            child: const CourseDetailTabletShimmer(
              constraints: BoxConstraints(maxWidth: 1280, maxHeight: 800),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(CourseDetailTabletShimmer), findsOneWidget);
        expect(find.byType(CourseDetailTabletTopBar), findsOneWidget);
        expect(find.byType(CourseDetailShimmer), findsNothing);
      },
    );
  });

  group('Course Recorded Lessons Shimmer Tests', () {
    testWidgets(
      'CourseRecordedLessonsTabletShimmer renders fixed top bar and two-pane skeleton',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          buildTestWidget(
            surfaceSize: const Size(1280, 800),
            child: const CourseRecordedLessonsTabletShimmer(),
          ),
        );
        await tester.pump();

        expect(find.byType(CourseRecordedLessonsTabletShimmer), findsOneWidget);
        expect(find.byType(CourseDetailTabletTopBar), findsOneWidget);
        expect(find.byType(CourseRecordedLessonsShimmer), findsNothing);
      },
    );
  });

  group('Course Online Lessons Shimmer Tests', () {
    testWidgets(
      'CourseOnlineLessonsTabletShimmer renders fixed top bar and 2-column online lesson cards',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          buildTestWidget(
            surfaceSize: const Size(1280, 800),
            child: const CourseOnlineLessonsTabletShimmer(),
          ),
        );
        await tester.pump();

        expect(find.byType(CourseOnlineLessonsTabletShimmer), findsOneWidget);
        expect(find.byType(CourseDetailTabletTopBar), findsOneWidget);
        expect(find.byType(CourseTabletOnlineLessonShimmerCard), findsWidgets);
        expect(find.byType(CourseOnlineLessonsShimmer), findsNothing);
      },
    );
  });

  group('Courses Tablet Main Navigation Shimmer Tests', () {
    testWidgets(
      'CoursesTabletShimmer renders responsive 2-column grid of CourseTabletShimmerCard',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 768));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          buildTestWidget(
            surfaceSize: const Size(1024, 768),
            child: const CoursesTabletShimmer(columnCount: 2, itemCount: 6),
          ),
        );
        await tester.pump();

        expect(find.byType(CoursesTabletShimmer), findsOneWidget);
        expect(find.byType(CourseTabletGrid), findsOneWidget);
        expect(find.byType(CourseTabletShimmerCard), findsNWidgets(6));
        expect(find.byType(CourseShimmerList), findsNothing);
      },
    );

    testWidgets(
      'CoursesTabletShimmer renders 3-column grid for wide tablet screens',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          buildTestWidget(
            surfaceSize: const Size(1280, 800),
            child: const CoursesTabletShimmer(columnCount: 3, itemCount: 6),
          ),
        );
        await tester.pump();

        expect(find.byType(CoursesTabletShimmer), findsOneWidget);
        expect(find.byType(CourseTabletGrid), findsOneWidget);
        expect(find.byType(CourseTabletShimmerCard), findsNWidgets(6));
      },
    );

    testWidgets(
      'CoursesTabletLandscape displays CoursesTabletShimmer during loading instead of mobile CourseShimmerList',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final classesCubit = FakeClassesCubit();
        final coursesCubit = FakeCoursesListCubit(loading: true);

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1280, 800)),
            child: ScreenUtilInit(
              designSize: const Size(420, 910),
              builder: (context, _) => MultiBlocProvider(
                providers: [
                  BlocProvider<ClassesCubit>.value(value: classesCubit),
                  BlocProvider<CoursesListCubit>.value(value: coursesCubit),
                ],
                child: const MaterialApp(
                  home: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Scaffold(
                      body: CoursesTabletLandscape(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(CoursesTabletShimmer), findsOneWidget);
        expect(find.byType(CourseTabletShimmerCard), findsWidgets);
        expect(find.byType(CourseShimmerList), findsNothing);
      },
    );
  });
}

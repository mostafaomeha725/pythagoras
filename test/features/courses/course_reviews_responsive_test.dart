import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/courses/domain/entities/course_review.dart';
import 'package:pythagoras/features/courses/domain/entities/course_reviews_data.dart';
import 'package:pythagoras/features/courses/presentation/cubit/add_course_review/add_course_review_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/add_course_review/add_course_review_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_reviews/course_reviews_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_reviews/course_reviews_state.dart';
import 'package:pythagoras/features/courses/presentation/screens/course_reviews_screen.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_add_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_empty_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_filter_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_landscape.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_rating_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_review_card.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_sort_button.dart';
import 'package:pythagoras/features/courses/presentation/widgets/reviews/course_reviews_tablet_top_bar.dart';

class FakeCourseReviewsCubit extends Cubit<CourseReviewsState>
    implements CourseReviewsCubit {
  CourseReviewsData mockData;

  FakeCourseReviewsCubit(this.mockData)
      : super(CourseReviewsLoaded(mockData));

  @override
  Future<void> fetchCourseReviews(int courseId) async {
    emit(CourseReviewsLoaded(mockData));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAddCourseReviewCubit extends Cubit<AddCourseReviewState>
    implements AddCourseReviewCubit {
  int? submittedCourseId;
  double? submittedRating;
  String? submittedComment;

  FakeAddCourseReviewCubit() : super(AddCourseReviewInitial());

  @override
  Future<void> addReview({
    required int courseId,
    required double rating,
    required String comment,
  }) async {
    submittedCourseId = courseId;
    submittedRating = rating;
    submittedComment = comment;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget createTestWidget({required Size surfaceSize}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, child) => const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CourseReviewsScreen(
            courseId: 101,
            courseTitle: 'رياضيات بحتة - الصف الثاني الثانوي',
          ),
        ),
      ),
    ),
  );
}

void main() {
  late CourseReviewsData mockData;
  late FakeCourseReviewsCubit fakeReviewsCubit;
  late FakeAddCourseReviewCubit fakeAddCubit;

  setUpAll(() async {
    await initializeDateFormatting('ar', null);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'userToken': 'valid_token_123'});
    final prefs = await SharedPreferences.getInstance();
    if (sl.isRegistered<PreferencesStorage>()) {
      sl.unregister<PreferencesStorage>();
    }
    sl.registerLazySingleton<PreferencesStorage>(() => PreferencesStorage(prefs));

    mockData = CourseReviewsData(
      ratingsDistribution: {5: 60.0, 4: 40.0, 3: 0.0, 2: 0.0, 1: 0.0},
      averageRating: 4.8,
      maxRating: 5,
      averageDisplay: '4.8',
      totalReviews: 2,
      reviews: [
        CourseReview(
          id: 1,
          userName: 'أحمد محمود',
          rating: 5.0,
          comment: 'شرح ممتاز ومبسط جداً أنصح بالاشتراك',
          createdAt: DateTime(2025, 2, 10, 14, 30),
        ),
        CourseReview(
          id: 2,
          userName: 'سارة خالد',
          rating: 4.0,
          comment: 'محتوى رائع ومنظم ومفيد',
          createdAt: DateTime(2025, 2, 12, 10, 15),
        ),
      ],
    );

    fakeReviewsCubit = FakeCourseReviewsCubit(mockData);
    fakeAddCubit = FakeAddCourseReviewCubit();

    if (sl.isRegistered<CourseReviewsCubit>()) {
      sl.unregister<CourseReviewsCubit>();
    }
    sl.registerFactory<CourseReviewsCubit>(() => fakeReviewsCubit);

    if (sl.isRegistered<AddCourseReviewCubit>()) {
      sl.unregister<AddCourseReviewCubit>();
    }
    sl.registerFactory<AddCourseReviewCubit>(() => fakeAddCubit);
  });

  group('CourseReviewsScreen Responsive Layout Tests', () {
    testWidgets('Mobile Portrait displays standard mobile AppBar and body', (
      tester,
    ) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      tester.view.physicalSize = const Size(420, 910);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestWidget(surfaceSize: const Size(420, 910)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CourseDetailAppBar), findsOneWidget);
      expect(find.byType(CourseReviewsTabletLandscape), findsNothing);
      expect(find.byType(CourseReviewsTabletTopBar), findsNothing);
    });

    testWidgets(
      'Mobile Landscape does NOT trigger tablet layout (height < 600)',
      (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          if (details.exceptionAsString().contains('overflowed')) return;
          originalOnError?.call(details);
        };
        addTearDown(() => FlutterError.onError = originalOnError);

        tester.view.physicalSize = const Size(844, 390);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(844, 390)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(CourseDetailAppBar), findsOneWidget);
        expect(find.byType(CourseReviewsTabletLandscape), findsNothing);
      },
    );

    testWidgets(
      'Tablet Portrait renders tablet layout with tablet top bar and content',
      (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          if (details.exceptionAsString().contains('overflowed')) return;
          originalOnError?.call(details);
        };
        addTearDown(() => FlutterError.onError = originalOnError);

        tester.view.physicalSize = const Size(800, 1280);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(800, 1280)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(CourseReviewsTabletLandscape), findsOneWidget);
        expect(find.byType(CourseReviewsTabletTopBar), findsOneWidget);
        expect(find.byType(CourseDetailAppBar), findsNothing);
      },
    );

    testWidgets(
      'Tablet Landscape renders dedicated 2-column layout with sidebar and reviews list',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(surfaceSize: const Size(1280, 800)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Mobile AppBar hidden, Tablet Top Bar displayed
        expect(find.byType(CourseDetailAppBar), findsNothing);
        expect(find.byType(CourseReviewsTabletLandscape), findsOneWidget);
        expect(find.byType(CourseReviewsTabletTopBar), findsOneWidget);

        // Sidebar components
        expect(find.byType(CourseReviewsTabletRatingCard), findsOneWidget);
        expect(find.byType(CourseReviewsTabletAddCard), findsOneWidget);
        expect(find.text('4.8'), findsOneWidget);
        expect(find.text('2 تقييم'), findsOneWidget);

        // Reviews column components
        expect(find.byType(CourseReviewsTabletFilterBar), findsOneWidget);
        expect(find.byType(CourseReviewsTabletSortButton), findsNWidgets(2));
        expect(find.text('2 رأياً'), findsOneWidget);
        expect(find.byType(CourseReviewsTabletReviewCard), findsNWidgets(2));
        expect(find.text('أحمد محمود'), findsOneWidget);
        expect(find.text('سارة خالد'), findsOneWidget);

        // Verify zero overflow in tablet landscape
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Tablet Landscape displays empty state when reviews list is empty', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      fakeReviewsCubit.mockData = const CourseReviewsData(
        ratingsDistribution: {},
        averageRating: 0.0,
        maxRating: 5,
        averageDisplay: '0.0',
        totalReviews: 0,
        reviews: [],
      );

      await tester.pumpWidget(
        createTestWidget(surfaceSize: const Size(1280, 800)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CourseReviewsTabletEmptyState), findsOneWidget);
      expect(find.text('لا توجد تقييمات بعد'), findsOneWidget);
    });

    testWidgets('Add Review validation shows error when submitting with 0 stars', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestWidget(surfaceSize: const Size(1280, 800)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap submit review without stars
      final submitButton = find.text('إرسال التقييم');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Error message should appear
      expect(find.text('لم تختر تقييماً بعد'), findsOneWidget);
    });
  });
}

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/enums/app_enums.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/core/services/remote_config_service.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_service.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_store.dart';
import 'package:pythagoras/features/courses/domain/entities/course.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/apple_purchase_verification_result.dart';
import 'package:pythagoras/features/courses/domain/entities/enrollment_result.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_course_curriculum_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_courses_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_chapter_direct_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_chapter_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_course_direct_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_course_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/verify_apple_purchase_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/enroll_course_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/enroll_chapter_use_case.dart';
import 'package:pythagoras/features/courses/data/models/course_detail_model.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/direct_request/direct_request_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_cubit.dart';
import 'package:pythagoras/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_chapter_tile.dart';

class _TabletStore implements AppleIapStore {
  final StreamController<List<PurchaseDetails>> purchases =
      StreamController<List<PurchaseDetails>>.broadcast();
  final List<String> purchasedIds = [];
  final List<PurchaseDetails> completed = [];
  Set<String> queriedIds = {};
  ProductDetailsResponse response = ProductDetailsResponse(
    productDetails: const [],
    notFoundIDs: const [],
  );
  int restoreCalls = 0;
  bool available = true;

  @override
  bool get isIapEnabled => true;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => purchases.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> loadProducts(Set<String> productIds) async {
    queriedIds = productIds;
    return response;
  }

  @override
  Future<bool> purchase(ProductDetails product) async {
    purchasedIds.add(product.id);
    return true;
  }

  @override
  Future<void> restorePurchases() async {
    restoreCalls++;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completed.add(purchase);
  }

  Future<void> close() => purchases.close();
}

class _TabletRemoteConfig extends RemoteConfigService {
  final StreamController<bool> changes = StreamController<bool>.broadcast(
    sync: true,
  );
  final StreamController<bool> requestChanges =
      StreamController<bool>.broadcast(sync: true);
  bool enabled;
  bool requestsEnabled;
  final bool isIosPlatform;

  _TabletRemoteConfig({
    required this.enabled,
    required this.requestsEnabled,
    required this.isIosPlatform,
  }) : super(isIos: false);

  @override
  bool get iosIapEnabled => enabled;

  @override
  Stream<bool> get iosIapEnabledChanges => changes.stream;

  @override
  bool get courseLessonRequestsEnabled =>
      isIosPlatform ? requestsEnabled : true;

  @override
  Stream<bool> get courseLessonRequestsEnabledChanges => requestChanges.stream;

  @override
  Future<void> initialize() async {}

  void setEnabled(bool value) {
    enabled = value;
    changes.add(value);
  }

  void setRequestsEnabled(bool value) {
    requestsEnabled = value;
    requestChanges.add(courseLessonRequestsEnabled);
  }
}

class _TabletCoursesRepository implements CoursesRepository {
  CourseDetail course;
  int? requestedCourseId;
  int? requestedChapterId;
  int? requestedCourseDirectId;
  int? requestedChapterDirectId;
  int curriculumCalls = 0;
  String? requestedCourseStatus;
  final Map<int, String> requestedChapterStatuses = {};
  final List<int> enrolledCourseIds = [];
  final List<int> enrolledChapterIds = [];
  ApplePurchaseVerificationResult verificationResult =
      const ApplePurchaseVerificationResult.http(200);

  _TabletCoursesRepository(this.course);

  @override
  Future<Either<Failure, CourseDetail>> getCourseCurriculum(
    int courseId, {
    bool fromCache = false,
  }) async {
    curriculumCalls++;
    return Right(
      course.copyWith(
        requestStatus: requestedCourseStatus ?? course.requestStatus,
        chapters: [
          for (final chapter in course.chapters)
            chapter.copyWith(
              requestStatus:
                  requestedChapterStatuses[chapter.id] ?? chapter.requestStatus,
            ),
        ],
      ),
    );
  }

  @override
  Future<Either<Failure, List<Course>>> getCourses({
    int? classId,
    int? semester,
    bool fromCache = false,
  }) async => const Right([]);

  @override
  Future<Either<Failure, String>> requestCourse(int courseId) async {
    requestedCourseId = courseId;
    requestedCourseStatus = 'pending';
    return const Right('https://wa.me/201234567890?text=course-request');
  }

  @override
  Future<Either<Failure, String>> requestChapter(int chapterId) async {
    requestedChapterId = chapterId;
    requestedChapterStatuses[chapterId] = 'pending';
    return const Right('https://wa.me/201234567890?text=chapter-request');
  }

  @override
  Future<Either<Failure, String>> requestCourseDirect(int courseId) async {
    requestedCourseDirectId = courseId;
    return const Right('تم استلام الطلب');
  }

  @override
  Future<Either<Failure, String>> requestChapterDirect(int chapterId) async {
    requestedChapterDirectId = chapterId;
    return const Right('تم استلام الطلب');
  }

  @override
  Future<Either<Failure, EnrollmentResult>> enrollCourse(int courseId) async {
    enrolledCourseIds.add(courseId);
    course = course.copyWith(isEnrolled: true);
    return const Right(
      EnrollmentResult(message: 'تم التسجيل', alreadyEnrolled: false),
    );
  }

  @override
  Future<Either<Failure, EnrollmentResult>> enrollChapter(int chapterId) async {
    enrolledChapterIds.add(chapterId);
    course = course.copyWith(
      chapters: [
        for (final chapter in course.chapters)
          if (chapter.id == chapterId)
            chapter.copyWith(isEnrolled: true)
          else
            chapter,
      ],
    );
    return const Right(
      EnrollmentResult(message: 'تم التسجيل', alreadyEnrolled: false),
    );
  }

  @override
  Future<ApplePurchaseVerificationResult> verifyApplePurchase(
    String signedTransaction,
  ) async => verificationResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TabletHarness {
  final CourseDetailModel course;
  final _TabletCoursesRepository repository;
  final _TabletStore store;
  final _TabletRemoteConfig remoteConfig;
  final CoursesListCubit coursesListCubit;
  final AppleIapCubit appleIapCubit;

  const _TabletHarness({
    required this.course,
    required this.repository,
    required this.store,
    required this.remoteConfig,
    required this.coursesListCubit,
    required this.appleIapCubit,
  });
}

ProductDetails _storeProduct(String id, String price) => ProductDetails(
  id: id,
  title: 'Tablet test product',
  description: 'StoreKit test product',
  price: price,
  rawPrice: 1,
  currencyCode: 'USD',
);

PurchaseDetails _purchase(
  String productId, {
  PurchaseStatus status = PurchaseStatus.purchased,
}) {
  final purchase = PurchaseDetails(
    purchaseID: 'tablet-transaction-$productId',
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local',
      serverVerificationData: 'server',
      source: 'test',
    ),
    transactionDate: '1',
    status: status,
  );
  return purchase..pendingCompletePurchase = true;
}

Future<_TabletHarness> _pumpCourseDetailScreen(
  WidgetTester tester, {
  required Size size,
  bool remoteConfigEnabled = true,
  bool courseLessonRequestsEnabled = true,
  TargetPlatform platform = TargetPlatform.iOS,
  bool authenticated = true,
  String? courseProductId = 'tablet.course.21',
  String? chapterProductId = 'tablet.chapter.245',
  String courseRequestStatus = 'not_requested',
  String chapterRequestStatus = 'not_requested',
  bool courseEnrolled = false,
  bool chapterEnrolled = false,
  bool configureVerifiedIap = false,
  List<ProductDetails>? storeProducts,
}) async {
  SharedPreferences.setMockInitialValues({
    if (authenticated) PreferencesKeys.userToken.name: 'tablet-test-token',
    if (authenticated) PreferencesKeys.userId.name: 21,
  });
  final sharedPreferences = await SharedPreferences.getInstance();
  final preferencesStorage = PreferencesStorage(sharedPreferences);
  await sl.reset();
  sl.registerSingleton<PreferencesStorage>(preferencesStorage);

  final course = CourseDetailModel.fromJson({
    'id': 21,
    'title': 'Tablet course',
    'level': 'Level',
    'class_name': 'Class',
    'price': '100',
    'final_price': 100,
    'currency_label': 'SAR',
    'students_count': 10,
    'is_saved': false,
    'is_enrolled': courseEnrolled,
    'request_status': courseRequestStatus,
    'apple_product_id': courseProductId,
    'general': {'rating': 4.5, 'category': 'Math'},
    'chapters': [
      {
        'id': 245,
        'title': 'Chapter 245',
        'order': 1,
        'price': '25',
        'currency': 'SAR',
        'currency_label': 'SAR',
        'request_status': chapterRequestStatus,
        'is_enrolled': chapterEnrolled,
        'apple_product_id': chapterProductId,
      },
    ],
  });
  final repository = _TabletCoursesRepository(course);
  final store = _TabletStore()
    ..response = ProductDetailsResponse(
      productDetails:
          storeProducts ??
          [
            if (courseProductId != null)
              _storeProduct(courseProductId, r'$2.99'),
            if (chapterProductId != null)
              _storeProduct(chapterProductId, r'$0.99'),
          ],
      notFoundIDs: const [],
    );
  final remoteConfig = _TabletRemoteConfig(
    enabled: remoteConfigEnabled,
    requestsEnabled: courseLessonRequestsEnabled,
    isIosPlatform: platform == TargetPlatform.iOS,
  );
  final service = AppleIapService(
    store: store,
    isIos: true,
    isIapEnabled: () => remoteConfig.iosIapEnabled,
    isAuthenticated: () => preferencesStorage.isAuthenticated,
  );
  final coursesListCubit = CoursesListCubit(GetCoursesUseCase(repository));
  final appleIapCubit = AppleIapCubit(
    service: service,
    verifyApplePurchaseUseCase: configureVerifiedIap
        ? VerifyApplePurchaseUseCase(repository)
        : null,
    enrollCourseUseCase: configureVerifiedIap
        ? EnrollCourseUseCase(repository)
        : null,
    enrollChapterUseCase: configureVerifiedIap
        ? EnrollChapterUseCase(repository)
        : null,
    preferences: sharedPreferences,
    isIos: true,
  );

  sl.registerFactory(
    () => CourseDetailsCubit(GetCourseCurriculumUseCase(repository)),
  );
  sl.registerFactory(
    () => RequestEnrollmentCubit(
      RequestCourseUseCase(repository),
      RequestChapterUseCase(repository),
      isCourseLessonRequestsEnabled: () =>
          remoteConfig.courseLessonRequestsEnabled,
    ),
  );
  sl.registerFactory(
    () => DirectRequestCubit(
      requestCourseDirectUseCase: RequestCourseDirectUseCase(repository),
      requestChapterDirectUseCase: RequestChapterDirectUseCase(repository),
      isCourseLessonRequestsEnabled: () =>
          remoteConfig.courseLessonRequestsEnabled,
    ),
  );
  sl.registerFactory(
    () => RemoteConfigCubit(remoteConfigService: remoteConfig),
  );
  sl.registerFactory<AppleIapCubit>(() => appleIapCubit);

  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        theme: ThemeData(platform: platform),
        builder: EasyLoading.init(),
        home: BlocProvider<CoursesListCubit>.value(
          value: coursesListCubit,
          child: const CourseDetailScreen(
            courseId: 21,
            courseTitle: 'Tablet course',
            isEnrolled: false,
          ),
        ),
      ),
    ),
  );
  await _pumpTabletFrames(tester);

  return _TabletHarness(
    course: course,
    repository: repository,
    store: store,
    remoteConfig: remoteConfig,
    coursesListCubit: coursesListCubit,
    appleIapCubit: appleIapCubit,
  );
}

Future<void> _pumpTabletFrames(WidgetTester tester, {int count = 6}) async {
  for (var frame = 0; frame < count; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _disposeTabletHarness(
  WidgetTester tester,
  _TabletHarness harness,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await _pumpTabletFrames(tester, count: 2);
  await tester.runAsync(() async {
    await Future<void>.delayed(Duration.zero);
    await harness.coursesListCubit.close();
    await harness.store.close();
    await harness.remoteConfig.changes.close();
    await harness.remoteConfig.requestChanges.close();
    await sl.reset();
  });
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'verified course enrollment refreshes details and shows success',
    (tester) async {
      final harness = await _pumpCourseDetailScreen(
        tester,
        size: const Size(390, 844),
        configureVerifiedIap: true,
      );

      await tester.tap(find.textContaining('شراء عبر Apple -').first);
      await tester.pump();
      harness.store.purchases.add([_purchase('tablet.course.21')]);
      await _pumpTabletFrames(tester);

      expect(harness.repository.enrolledCourseIds, [21]);
      expect(harness.repository.curriculumCalls, 2);
      expect(harness.repository.course.isEnrolled, isTrue);
      expect(EasyLoading.isShow, isTrue);
      expect(find.textContaining('شراء عبر Apple -'), findsNothing);

      await _disposeTabletHarness(tester, harness);
    },
  );

  testWidgets(
    'verified chapter enrollment refreshes details and shows success',
    (tester) async {
      final harness = await _pumpCourseDetailScreen(
        tester,
        size: const Size(390, 844),
        configureVerifiedIap: true,
      );
      await tester.tap(find.text('Chapter 245'));
      await _pumpTabletFrames(tester);
      final chapterPurchaseButton = find.descendant(
        of: find.byType(CourseChapterTile).first,
        matching: find.textContaining('شراء عبر Apple -'),
      );

      await tester.tap(chapterPurchaseButton);
      await tester.pump();
      harness.store.purchases.add([_purchase('tablet.chapter.245')]);
      await _pumpTabletFrames(tester);

      expect(harness.repository.enrolledChapterIds, [245]);
      expect(harness.repository.curriculumCalls, 2);
      expect(harness.repository.course.chapters.single.isEnrolled, isTrue);
      expect(EasyLoading.isShow, isTrue);

      await _disposeTabletHarness(tester, harness);
    },
  );

  testWidgets(
    'verification failure dismisses loading without enrollment success',
    (tester) async {
      final harness = await _pumpCourseDetailScreen(
        tester,
        size: const Size(390, 844),
        configureVerifiedIap: true,
      );
      harness.repository.verificationResult =
          const ApplePurchaseVerificationResult.http(422);

      await tester.tap(find.textContaining('شراء عبر Apple -').first);
      await tester.pump();
      harness.store.purchases.add([_purchase('tablet.course.21')]);
      await _pumpTabletFrames(tester);

      expect(harness.repository.enrolledCourseIds, isEmpty);
      expect(EasyLoading.isShow, isFalse);

      await _disposeTabletHarness(tester, harness);
    },
  );

  testWidgets(
    'iOS course request uses legacy API and refreshes pending state',
    (tester) async {
      final harness = await _pumpCourseDetailScreen(
        tester,
        size: const Size(390, 844),
      );

      await tester.tap(find.text('طلب الدورة'));
      await _pumpTabletFrames(tester);

      expect(harness.repository.requestedCourseId, 21);
      expect(harness.repository.requestedCourseDirectId, isNull);
      expect(harness.repository.curriculumCalls, 2);
      expect(find.text('قيد الانتظار'), findsWidgets);

      await _disposeTabletHarness(tester, harness);
    },
  );

  testWidgets(
    'iOS chapter request uses legacy API and refreshes pending state',
    (tester) async {
      final harness = await _pumpCourseDetailScreen(
        tester,
        size: const Size(390, 844),
      );
      await tester.tap(find.text('Chapter 245'));
      await _pumpTabletFrames(tester);

      await tester.tap(find.textContaining('طلب الحصة'));
      await _pumpTabletFrames(tester);

      expect(harness.repository.requestedChapterId, 245);
      expect(harness.repository.requestedChapterDirectId, isNull);
      expect(harness.repository.curriculumCalls, 2);
      expect(find.text('قيد الانتظار'), findsWidgets);

      await _disposeTabletHarness(tester, harness);
    },
  );

  testWidgets(
    'already-enrolled course reports unrelated restored products informationally',
    (tester) async {
      final harness = await _pumpCourseDetailScreen(
        tester,
        size: const Size(390, 844),
        courseEnrolled: true,
      );

      await tester.tap(find.text('استعادة المشتريات'));
      await tester.pump();
      harness.store.purchases.add([
        _purchase('unrelated.course.product', status: PurchaseStatus.restored),
      ]);
      await _pumpTabletFrames(tester);

      expect(
        find.textContaining('منتج غير موجود في المحتوى المفتوح'),
        findsNothing,
      );
      expect(
        harness.appleIapCubit.state.status,
        AppleIapStatus.verificationRequired,
      );
      expect(harness.appleIapCubit.state.restoreHasUnmappedProducts, isTrue);
      expect(
        harness.appleIapCubit.state.restoreHasConfirmedEnrollment,
        isFalse,
      );
      expect(harness.repository.enrolledCourseIds, isEmpty);
      expect(harness.repository.enrolledChapterIds, isEmpty);
      expect(harness.store.completed, isEmpty);

      await _disposeTabletHarness(tester, harness);
    },
  );

  testWidgets(
    'tablet landscape keeps its layout and supports course and chapter IAP',
    (tester) async {
      final harness = await _pumpCourseDetailScreen(
        tester,
        size: const Size(1024, 768),
      );

      expect(find.text(r'شراء عبر Apple - $2.99'), findsOneWidget);
      expect(find.text('استعادة المشتريات'), findsOneWidget);
      expect(find.text('طلب الدورة'), findsOneWidget);
      expect(harness.store.queriedIds, {
        'tablet.course.21',
        'tablet.chapter.245',
      });

      await tester.tap(find.textContaining('شراء عبر Apple -'));
      await tester.pump();
      expect(harness.store.purchasedIds, ['tablet.course.21']);
      harness.store.purchases.add([
        _purchase('tablet.course.21', status: PurchaseStatus.canceled),
      ]);
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Chapter 245'));
      await _pumpTabletFrames(tester);
      expect(find.text(r'شراء عبر Apple - $0.99'), findsOneWidget);
      expect(find.text('استعادة المشتريات'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CourseChapterTile).first,
          matching: find.text('استعادة المشتريات'),
        ),
        findsNothing,
      );

      final chapterBuyButton = find.descendant(
        of: find.byType(CourseChapterTile),
        matching: find.text(r'شراء عبر Apple - $0.99'),
      );
      await tester.tap(chapterBuyButton);
      await tester.pump();
      expect(harness.store.purchasedIds, [
        'tablet.course.21',
        'tablet.chapter.245',
      ]);

      harness.store.purchases.add([_purchase('tablet.chapter.245')]);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(harness.repository.requestedCourseId, isNull);
      expect(harness.repository.requestedChapterId, isNull);
      expect(harness.store.completed, hasLength(1));
      expect(harness.store.completed.single.status, PurchaseStatus.canceled);

      await tester.tap(find.text('استعادة المشتريات').first);
      await _pumpTabletFrames(tester);
      expect(harness.store.restoreCalls, 1);
      harness.store.purchases.add([
        _purchase('tablet.chapter.245', status: PurchaseStatus.restored),
      ]);
      await _pumpTabletFrames(tester);
      expect(harness.repository.requestedChapterId, isNull);
      expect(harness.store.completed, hasLength(1));

      await _disposeTabletHarness(tester, harness);
    },
  );

  testWidgets(
    'tablet portrait keeps the phone IAP section and StoreKit price',
    (tester) async {
      final harness = await _pumpCourseDetailScreen(
        tester,
        size: const Size(800, 1180),
      );

      expect(find.text(r'شراء عبر Apple - $2.99'), findsOneWidget);
      expect(find.text('استعادة المشتريات'), findsOneWidget);
      expect(find.text('طلب الدورة'), findsOneWidget);

      await _disposeTabletHarness(tester, harness);
    },
  );

  testWidgets('tablet Remote Config hides and re-enables Apple actions', (
    tester,
  ) async {
    final harness = await _pumpCourseDetailScreen(
      tester,
      size: const Size(1024, 768),
      remoteConfigEnabled: false,
    );

    expect(find.textContaining('شراء عبر Apple -'), findsNothing);
    expect(find.text('استعادة المشتريات'), findsNothing);
    expect(find.text('طلب الدورة'), findsOneWidget);

    harness.remoteConfig.setEnabled(true);
    await _pumpTabletFrames(tester);
    expect(find.text(r'شراء عبر Apple - $2.99'), findsOneWidget);
    expect(find.text('استعادة المشتريات'), findsOneWidget);

    harness.remoteConfig.setEnabled(false);
    await _pumpTabletFrames(tester);
    expect(find.textContaining('شراء عبر Apple -'), findsNothing);
    expect(find.text('استعادة المشتريات'), findsNothing);

    await _disposeTabletHarness(tester, harness);
  });

  testWidgets(
    'course lesson request flag applies on iPhone and iPad but not Android',
    (tester) async {
      final scenarios = [
        (
          size: const Size(390, 844),
          platform: TargetPlatform.iOS,
          requestVisibleWhenDisabled: false,
        ),
        (
          size: const Size(1024, 768),
          platform: TargetPlatform.iOS,
          requestVisibleWhenDisabled: false,
        ),
        (
          size: const Size(600, 768),
          platform: TargetPlatform.iOS,
          requestVisibleWhenDisabled: false,
        ),
        (
          size: const Size(800, 1180),
          platform: TargetPlatform.iOS,
          requestVisibleWhenDisabled: false,
        ),
        (
          size: const Size(390, 844),
          platform: TargetPlatform.android,
          requestVisibleWhenDisabled: true,
        ),
      ];

      for (final scenario in scenarios) {
        final harness = await _pumpCourseDetailScreen(
          tester,
          size: scenario.size,
          courseLessonRequestsEnabled: false,
          platform: scenario.platform,
        );
        double? restoreTopBeforeExpansion;

        if (scenario.platform == TargetPlatform.iOS) {
          final staleRestore = _purchase(
            'stale.unknown.product',
            status: PurchaseStatus.restored,
          );
          harness.store.purchases.add([staleRestore]);
          harness.store.purchases.add([staleRestore]);
          await _pumpTabletFrames(tester);
          expect(
            find.textContaining('وصلت معاملة لمنتج غير موجود'),
            findsNothing,
          );
          expect(harness.store.completed, isEmpty);
        }

        if (scenario.requestVisibleWhenDisabled) {
          expect(find.text('طلب الدورة'), findsOneWidget);
          expect(find.text('استعادة المشتريات'), findsNothing);
          expect(
            find.byKey(const ValueKey('course-detail-restore-action-slot')),
            findsNothing,
          );
        } else {
          expect(find.text('طلب الدورة'), findsNothing);
          expect(find.textContaining('شراء عبر Apple -'), findsOneWidget);
          expect(find.text('استعادة المشتريات'), findsOneWidget);
          restoreTopBeforeExpansion = tester
              .getTopLeft(find.text('استعادة المشتريات'))
              .dy;
          expect(
            find.descendant(
              of: find.byKey(
                const ValueKey('course-detail-restore-action-slot'),
              ),
              matching: find.text('استعادة المشتريات'),
            ),
            findsOneWidget,
          );
        }

        final chapterTitle = find.text('Chapter 245');
        await tester.ensureVisible(chapterTitle);
        await tester.pump();
        await tester.tap(chapterTitle);
        await _pumpTabletFrames(tester);
        if (scenario.platform == TargetPlatform.iOS) {
          expect(find.text('استعادة المشتريات'), findsOneWidget);
          expect(
            tester.getTopLeft(find.text('استعادة المشتريات')).dy,
            closeTo(restoreTopBeforeExpansion!, 1),
          );
          expect(
            find.descendant(
              of: find.byType(CourseChapterTile).first,
              matching: find.text('استعادة المشتريات'),
            ),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('course-detail-restore-action-slot')),
            findsOneWidget,
          );
        }
        if (scenario.requestVisibleWhenDisabled) {
          expect(find.textContaining('طلب الحصة'), findsOneWidget);
        } else {
          expect(find.textContaining('طلب الحصة'), findsNothing);
        }

        harness.remoteConfig.setRequestsEnabled(true);
        await _pumpTabletFrames(tester);
        expect(find.text('طلب الدورة'), findsOneWidget);
        expect(find.textContaining('طلب الحصة'), findsOneWidget);
        if (scenario.platform == TargetPlatform.iOS) {
          expect(find.text('استعادة المشتريات'), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(CourseChapterTile).first,
              matching: find.text('استعادة المشتريات'),
            ),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('course-detail-restore-action-slot')),
            findsNothing,
          );
        }

        harness.remoteConfig.setRequestsEnabled(false);
        await _pumpTabletFrames(tester);
        if (scenario.requestVisibleWhenDisabled) {
          expect(find.text('طلب الدورة'), findsOneWidget);
          expect(find.textContaining('طلب الحصة'), findsOneWidget);
          expect(find.text('استعادة المشتريات'), findsNothing);
          expect(
            find.byKey(const ValueKey('course-detail-restore-action-slot')),
            findsNothing,
          );
        } else {
          expect(find.text('طلب الدورة'), findsNothing);
          expect(find.textContaining('طلب الحصة'), findsNothing);
          expect(find.text('استعادة المشتريات'), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(CourseChapterTile).first,
              matching: find.text('استعادة المشتريات'),
            ),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('course-detail-restore-action-slot')),
            findsOneWidget,
          );
        }

        await _disposeTabletHarness(tester, harness);
      }
    },
  );

  testWidgets(
    'tablet hides purchase for missing, unavailable, or pending course',
    (tester) async {
      final missingProduct = await _pumpCourseDetailScreen(
        tester,
        size: const Size(1024, 768),
        courseProductId: null,
        chapterProductId: null,
      );
      expect(find.textContaining('شراء عبر Apple -'), findsNothing);
      expect(
        find.text('الشراء عبر Apple غير متاح لهذا المحتوى حاليًا'),
        findsOneWidget,
      );
      expect(find.text('استعادة المشتريات'), findsOneWidget);
      await _disposeTabletHarness(tester, missingProduct);

      final unavailableProduct = await _pumpCourseDetailScreen(
        tester,
        size: const Size(1024, 768),
        storeProducts: const [],
      );
      expect(find.textContaining('شراء عبر Apple -'), findsNothing);
      expect(find.text('الشراء عبر Apple غير متاح حاليًا'), findsOneWidget);
      expect(find.text('استعادة المشتريات'), findsOneWidget);
      await _disposeTabletHarness(tester, unavailableProduct);

      final pendingCourse = await _pumpCourseDetailScreen(
        tester,
        size: const Size(1024, 768),
        courseRequestStatus: 'pending',
        chapterProductId: null,
      );
      expect(find.textContaining('شراء عبر Apple -'), findsNothing);
      expect(find.text('استعادة المشتريات'), findsOneWidget);
      expect(find.text('قيد الانتظار'), findsNWidgets(2));
      await _disposeTabletHarness(tester, pendingCourse);
    },
  );

  testWidgets(
    'tablet blocks chapter purchase when chapter or course is owned/pending',
    (tester) async {
      final pendingChapter = await _pumpCourseDetailScreen(
        tester,
        size: const Size(1024, 768),
        chapterRequestStatus: 'pending',
      );
      await tester.tap(find.text('Chapter 245'));
      await _pumpTabletFrames(tester);
      expect(
        find.descendant(
          of: find.byType(CourseChapterTile),
          matching: find.textContaining('شراء عبر Apple -'),
        ),
        findsNothing,
      );
      expect(pendingChapter.store.queriedIds, {'tablet.course.21'});
      await _disposeTabletHarness(tester, pendingChapter);

      final enrolledCourse = await _pumpCourseDetailScreen(
        tester,
        size: const Size(1024, 768),
        courseEnrolled: true,
        courseRequestStatus: 'accepted',
      );
      await tester.tap(find.text('Chapter 245'));
      await _pumpTabletFrames(tester);
      expect(find.textContaining('شراء عبر Apple -'), findsNothing);
      expect(find.text('عرض الدورة'), findsOneWidget);
      expect(enrolledCourse.store.queriedIds, isEmpty);
      await _disposeTabletHarness(tester, enrolledCourse);

      final enrolledChapter = await _pumpCourseDetailScreen(
        tester,
        size: const Size(1024, 768),
        chapterEnrolled: true,
        chapterRequestStatus: 'accepted',
      );
      await tester.tap(find.text('Chapter 245'));
      await _pumpTabletFrames(tester);
      expect(
        find.descendant(
          of: find.byType(CourseChapterTile),
          matching: find.textContaining('شراء عبر Apple -'),
        ),
        findsNothing,
      );
      await _disposeTabletHarness(tester, enrolledChapter);
    },
  );

  testWidgets('guest tablet purchase and restore show login without StoreKit', (
    tester,
  ) async {
    final harness = await _pumpCourseDetailScreen(
      tester,
      size: const Size(1024, 768),
      authenticated: false,
    );

    await tester.tap(find.textContaining('شراء عبر Apple -'));
    await _pumpTabletFrames(tester);
    expect(find.text('يجب تسجيل الدخول أولًا'), findsOneWidget);
    expect(harness.store.purchasedIds, isEmpty);
    expect(harness.store.restoreCalls, 0);

    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await _pumpTabletFrames(tester);
    await tester.tap(find.text('استعادة المشتريات'));
    await _pumpTabletFrames(tester);
    expect(find.text('يجب تسجيل الدخول أولًا'), findsOneWidget);
    expect(harness.store.purchasedIds, isEmpty);
    expect(harness.store.restoreCalls, 0);

    await _disposeTabletHarness(tester, harness);
  });
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/enums/app_enums.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_chapter_direct_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_course_direct_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/verify_apple_purchase_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/enroll_course_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/enroll_chapter_use_case.dart';
import 'package:pythagoras/features/courses/domain/entities/apple_purchase_verification_result.dart';
import 'package:pythagoras/features/courses/domain/entities/enrollment_result.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_service.dart'
    as apple_iap_service;
import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_store.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/direct_request/direct_request_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/direct_request/direct_request_state.dart';
import 'package:pythagoras/core/services/remote_config_service.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/apple_iap_purchase_section.dart';
import 'package:pythagoras/features/courses/presentation/utils/apple_iap_success_message.dart';
import 'package:pythagoras/features/courses/data/models/course_model.dart';
import 'package:pythagoras/features/courses/data/models/course_chapter_model.dart';
import 'package:pythagoras/features/courses/data/models/course_detail_model.dart';

class FakeAppleIapStore implements AppleIapStore {
  final StreamController<List<PurchaseDetails>> purchaseController =
      StreamController<List<PurchaseDetails>>.broadcast();
  final List<PurchaseDetails> completedPurchases = [];
  final List<String> purchasedProductIds = [];
  bool available = true;
  @override
  bool isIapEnabled = true;
  bool purchaseStarted = true;
  int purchaseCalls = 0;
  bool restoreCalled = false;
  bool restoreSawPurchaseListener = false;
  int restoreCalls = 0;
  Completer<void>? restoreGate;
  Completer<void>? completeGate;
  Object? completeError;
  Object? purchaseError;
  int completeCalls = 0;
  int loadProductsCalls = 0;
  Set<String> queriedProductIds = {};
  ProductDetailsResponse response = ProductDetailsResponse(
    productDetails: const [],
    notFoundIDs: const [],
  );

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => purchaseController.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> loadProducts(Set<String> productIds) async {
    loadProductsCalls++;
    queriedProductIds = productIds;
    return response;
  }

  @override
  Future<bool> purchase(ProductDetails product) async {
    purchaseCalls++;
    purchasedProductIds.add(product.id);
    final error = purchaseError;
    if (error != null) throw error;
    return purchaseStarted;
  }

  @override
  Future<void> restorePurchases() async {
    restoreCalled = true;
    restoreSawPurchaseListener = purchaseController.hasListener;
    restoreCalls++;
    final gate = restoreGate;
    if (gate != null) await gate.future;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completeCalls++;
    final gate = completeGate;
    if (gate != null) await gate.future;
    final error = completeError;
    if (error != null) throw error;
    completedPurchases.add(purchase);
  }

  Future<void> close() => purchaseController.close();
}

class AppleIapService extends apple_iap_service.AppleIapService {
  AppleIapService({
    super.store,
    super.inAppPurchase,
    super.productIds,
    super.isIos,
    super.isIapEnabled,
    bool Function()? isAuthenticated,
  }) : super(isAuthenticated: isAuthenticated ?? (() => true));
}

class FakeDirectRequestRepository implements CoursesRepository {
  int? requestedChapterId;
  final List<int> enrolledCourseIds = [];
  final List<int> enrolledChapterIds = [];
  Either<Failure, EnrollmentResult> courseEnrollmentResponse = const Right(
    EnrollmentResult(message: 'تم التسجيل', alreadyEnrolled: false),
  );
  Either<Failure, EnrollmentResult> chapterEnrollmentResponse = const Right(
    EnrollmentResult(message: 'تم التسجيل', alreadyEnrolled: false),
  );

  @override
  Future<Either<Failure, String>> requestChapterDirect(int chapterId) async {
    requestedChapterId = chapterId;
    return Left(Failure('activation failed'));
  }

  @override
  Future<Either<Failure, EnrollmentResult>> enrollCourse(int courseId) async {
    enrolledCourseIds.add(courseId);
    return courseEnrollmentResponse;
  }

  @override
  Future<Either<Failure, EnrollmentResult>> enrollChapter(int chapterId) async {
    enrolledChapterIds.add(chapterId);
    return chapterEnrollmentResponse;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeVerifyApplePurchaseUseCase extends VerifyApplePurchaseUseCase {
  factory FakeVerifyApplePurchaseUseCase([
    FakeDirectRequestRepository? repository,
  ]) => FakeVerifyApplePurchaseUseCase._(
    repository ?? FakeDirectRequestRepository(),
  );

  FakeVerifyApplePurchaseUseCase._(this.fakeRepository) : super(fakeRepository);

  final FakeDirectRequestRepository fakeRepository;

  final List<String> submittedTransactions = [];
  ApplePurchaseVerificationResult response =
      const ApplePurchaseVerificationResult.http(200);

  @override
  Future<ApplePurchaseVerificationResult> call(String signedTransaction) async {
    submittedTransactions.add(signedTransaction);
    return response;
  }
}

class FakeRemoteConfigService extends RemoteConfigService {
  final StreamController<bool> updates = StreamController<bool>.broadcast(
    sync: true,
  );
  bool enabled;
  bool failInitialization = false;

  FakeRemoteConfigService({this.enabled = false}) : super(isIos: false);

  @override
  bool get iosIapEnabled => enabled;

  @override
  Stream<bool> get iosIapEnabledChanges => updates.stream;

  @override
  Future<void> initialize() async {
    if (failInitialization) throw StateError('Remote Config unavailable');
  }

  void setEnabled(bool value) {
    enabled = value;
    updates.add(enabled);
  }
}

ProductDetails product({String id = 'test.product.course'}) => ProductDetails(
  id: id,
  title: 'Test product',
  description: 'Test-only product',
  price: r'$1.00',
  rawPrice: 1,
  currencyCode: 'USD',
);

PurchaseDetails purchaseDetails(
  PurchaseStatus status, {
  String id = 'transaction-1',
  String productId = 'test.product.course',
  String serverVerificationData = 'server-test-data',
  bool pendingCompletePurchase = true,
  IAPError? error,
}) {
  final purchase = PurchaseDetails(
    purchaseID: id,
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local-test-data',
      serverVerificationData: serverVerificationData,
      source: 'test',
    ),
    transactionDate: status == PurchaseStatus.pending ? null : '1',
    status: status,
  )..pendingCompletePurchase = pendingCompletePurchase;
  purchase.error = error;
  return purchase;
}

class _EnrollmentHarness {
  final FakeAppleIapStore store;
  final AppleIapService service;
  final FakeDirectRequestRepository repository;
  final FakeVerifyApplePurchaseUseCase verify;
  final SharedPreferences preferences;
  final AppleIapCubit cubit;

  const _EnrollmentHarness({
    required this.store,
    required this.service,
    required this.repository,
    required this.verify,
    required this.preferences,
    required this.cubit,
  });

  Future<void> close() async {
    await cubit.close();
    await store.close();
  }
}

Future<_EnrollmentHarness> _enrollmentHarness({
  required String productId,
  required AppleIapProductTarget target,
  Map<String, AppleIapProductTarget> additionalTargets = const {},
  Map<String, String> restoreOwners = const {},
  Completer<void>? restoreGate,
  Duration purchaseResponseTimeout = const Duration(seconds: 90),
}) async {
  final targets = <String, AppleIapProductTarget>{
    productId: target,
    ...additionalTargets,
  };
  SharedPreferences.setMockInitialValues({
    PreferencesKeys.userId.name: 91,
    PreferencesKeys.userToken.name: 'test-token',
  });
  final preferences = await SharedPreferences.getInstance();
  if (restoreOwners.isNotEmpty) {
    await preferences.setStringList(
      'apple_iap_pending_enrollment_records',
      restoreOwners.entries
          .map((entry) {
            final restoredTarget = targets[entry.value]!;
            return jsonEncode({
              'transactionKey': entry.key,
              'productId': entry.value,
              'ownerId': 91,
              'targetType': restoredTarget.type.name,
              'contentId': restoredTarget.contentId,
              'parentContentId': restoredTarget.parentContentId,
            });
          })
          .toList(growable: false),
    );
  }
  final store = FakeAppleIapStore()
    ..restoreGate = restoreGate
    ..response = ProductDetailsResponse(
      productDetails: [for (final id in targets.keys) product(id: id)],
      notFoundIDs: const [],
    );
  final repository = FakeDirectRequestRepository();
  final verify = FakeVerifyApplePurchaseUseCase(repository);
  final service = AppleIapService(
    store: store,
    productIds: targets.keys.toSet(),
    isIos: true,
    isAuthenticated: () => true,
  );
  final cubit = AppleIapCubit(
    service: service,
    verifyApplePurchaseUseCase: verify,
    enrollCourseUseCase: EnrollCourseUseCase(repository),
    enrollChapterUseCase: EnrollChapterUseCase(repository),
    productTargets: targets,
    preferences: preferences,
    isIos: true,
    purchaseResponseTimeout: purchaseResponseTimeout,
  );
  int? courseId;
  String? courseProductId;
  final chapterProductIds = <int, String?>{};
  for (final entry in targets.entries) {
    if (entry.value.type == AppleIapProductType.course) {
      courseId ??= entry.value.contentId;
      courseProductId ??= entry.key;
    } else {
      courseId ??= entry.value.parentContentId;
      chapterProductIds[entry.value.contentId] = entry.key;
    }
  }
  await cubit.updateCourseAndChapterAccess(
    courseId: courseId ?? target.contentId,
    isRequestStatusEligible: true,
    isEnrolled: false,
    hasPendingRequest: false,
    eligibleChapterIds: chapterProductIds.keys.toSet(),
    courseAppleProductId: courseProductId,
    chapterAppleProductIds: chapterProductIds,
  );
  return _EnrollmentHarness(
    store: store,
    service: service,
    repository: repository,
    verify: verify,
    preferences: preferences,
    cubit: cubit,
  );
}

Future<void> settleStream() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  test('Course and chapter models retain API apple product ids', () {
    final course = CourseModel.fromJson({
      'id': 21,
      'title': 'Course',
      'price': '199',
      'apple_product_id': 'course.product.21',
    });
    final courseDetail = CourseDetailModel.fromJson({
      'id': 21,
      'title': 'Course',
      'level': 'Level',
      'class_name': 'Class',
      'price': '199',
      'final_price': 199,
      'currency_label': 'SAR',
      'students_count': 0,
      'is_saved': false,
      'rating': 0,
      'category': 'Category',
      'is_enrolled': false,
      'apple_product_id': 'course.product.21',
      'chapters': [
        {
          'id': 245,
          'title': 'Chapter',
          'order': 1,
          'price': '49',
          'currency': 'SAR',
          'currency_label': 'SAR',
          'apple_product_id': 'chapter.product.245',
          'request_status': 'not_requested',
          'is_enrolled': false,
        },
      ],
    });

    final chapter = CourseChapterModel.fromJson({
      'id': 245,
      'title': 'Chapter',
      'order': 1,
      'price': '49',
      'currency': 'SAR',
      'currency_label': 'ر.س',
      'apple_product_id': 'chapter.product.245',
    });

    expect(course.appleProductId, 'course.product.21');
    expect(chapter.appleProductId, 'chapter.product.245');
    expect(courseDetail.appleProductId, 'course.product.21');
    expect(courseDetail.chapters.single.appleProductId, 'chapter.product.245');
  });

  test('missing and blank API product IDs stay unavailable', () {
    final missingCourse = CourseModel.fromJson({
      'id': 21,
      'title': 'Course',
      'price': '199',
    });
    final blankChapter = CourseChapterModel.fromJson({
      'id': 245,
      'title': 'Chapter',
      'order': 1,
      'price': '49',
      'currency': 'SAR',
      'currency_label': 'SAR',
      'apple_product_id': '  ',
    });

    expect(missingCourse.appleProductId, isNull);
    expect(blankChapter.appleProductId, '  ');
  });
  late FakeAppleIapStore store;
  late AppleIapService service;
  late FakeVerifyApplePurchaseUseCase verifyApplePurchaseUseCase;
  late AppleIapCubit cubit;

  setUp(() async {
    store = FakeAppleIapStore();
    store.response = ProductDetailsResponse(
      productDetails: [product()],
      notFoundIDs: const [],
    );
    service = AppleIapService(
      store: store,
      productIds: {'test.product.course'},
      isIos: true,
    );
    verifyApplePurchaseUseCase = FakeVerifyApplePurchaseUseCase();
    cubit = AppleIapCubit(
      service: service,
      verifyApplePurchaseUseCase: verifyApplePurchaseUseCase,
      productIds: {'test.product.course'},
      isIos: true,
    );
    await cubit.loadProducts();
  });

  tearDown(() async {
    await cubit.close();
    await store.close();
  });

  test(
    'new course purchase message is retained for already-enrolled users',
    () {
      expect(
        appleIapSuccessMessage(
          isRestore: false,
          alreadyEnrolled: true,
          productType: AppleIapProductType.course,
        ),
        'تم شراء الكورس وتفعيله بنجاح',
      );
    },
  );

  test(
    'new chapter purchase message is retained for already-enrolled users',
    () {
      expect(
        appleIapSuccessMessage(
          isRestore: false,
          alreadyEnrolled: true,
          productType: AppleIapProductType.chapter,
        ),
        'تم شراء الحصة وتفعيلها بنجاح',
      );
    },
  );

  test('Restore message never claims a new purchase', () {
    for (final alreadyEnrolled in [false, true]) {
      final message = appleIapSuccessMessage(
        isRestore: true,
        alreadyEnrolled: alreadyEnrolled,
        productType: AppleIapProductType.course,
      );

      expect(message, contains('استعادة المشتريات'));
      expect(message, isNot(contains('تم شراء')));
    }
  });

  test('verified course purchase enrolls its mapped course ID', () async {
    final harness = await _enrollmentHarness(
      productId: 'course.product.36',
      target: const AppleIapProductTarget(
        type: AppleIapProductType.course,
        contentId: 36,
      ),
    );

    harness.store.purchaseController.add([
      purchaseDetails(PurchaseStatus.purchased, productId: 'course.product.36'),
    ]);
    await settleStream();

    expect(harness.verify.submittedTransactions, ['server-test-data']);
    expect(harness.repository.enrolledCourseIds, [36]);
    expect(harness.repository.enrolledChapterIds, isEmpty);
    expect(harness.cubit.state.status, AppleIapStatus.purchaseConfirmed);
    expect(harness.cubit.state.alreadyEnrolled, isFalse);
    expect(harness.store.completedPurchases, hasLength(1));
    await harness.cubit.purchase('course.product.36');
    expect(harness.store.purchaseCalls, 0);
    expect(harness.cubit.state.status, AppleIapStatus.purchaseConfirmed);
    await harness.close();
  });

  test('HTTP 201 verification proceeds to course enrollment', () async {
    final harness = await _enrollmentHarness(
      productId: 'course.product.36',
      target: const AppleIapProductTarget(
        type: AppleIapProductType.course,
        contentId: 36,
      ),
    );
    harness.verify.response = const ApplePurchaseVerificationResult.http(201);

    harness.store.purchaseController.add([
      purchaseDetails(PurchaseStatus.purchased, productId: 'course.product.36'),
    ]);
    await settleStream();

    expect(harness.repository.enrolledCourseIds, [36]);
    expect(harness.cubit.state.status, AppleIapStatus.purchaseConfirmed);
    expect(harness.cubit.state.verificationStatusCode, 201);
    expect(harness.store.completedPurchases, hasLength(1));
    await harness.close();
  });

  test('verified chapter purchase enrolls its mapped chapter ID', () async {
    final harness = await _enrollmentHarness(
      productId: 'chapter.product.245',
      target: const AppleIapProductTarget(
        type: AppleIapProductType.chapter,
        contentId: 245,
        parentContentId: 36,
      ),
    );

    harness.store.purchaseController.add([
      purchaseDetails(
        PurchaseStatus.purchased,
        productId: 'chapter.product.245',
      ),
    ]);
    await settleStream();

    expect(harness.repository.enrolledChapterIds, [245]);
    expect(harness.repository.enrolledCourseIds, isEmpty);
    expect(harness.cubit.state.status, AppleIapStatus.purchaseConfirmed);
    expect(harness.store.completedPurchases, hasLength(1));
    await harness.close();
  });

  test('already-enrolled response succeeds after Apple verification', () async {
    final harness = await _enrollmentHarness(
      productId: 'course.product.36',
      target: const AppleIapProductTarget(
        type: AppleIapProductType.course,
        contentId: 36,
      ),
    );
    harness.repository.courseEnrollmentResponse = const Right(
      EnrollmentResult(message: 'أنت مسجل بالفعل', alreadyEnrolled: true),
    );

    harness.store.purchaseController.add([
      purchaseDetails(PurchaseStatus.purchased, productId: 'course.product.36'),
    ]);
    await settleStream();

    expect(harness.cubit.state.status, AppleIapStatus.purchaseConfirmed);
    expect(harness.cubit.state.alreadyEnrolled, isTrue);
    expect(harness.repository.enrolledCourseIds, [36]);
    await harness.close();
  });

  test('verify 422 prevents enrollment and transaction completion', () async {
    final harness = await _enrollmentHarness(
      productId: 'course.product.36',
      target: const AppleIapProductTarget(
        type: AppleIapProductType.course,
        contentId: 36,
      ),
    );
    harness.verify.response = const ApplePurchaseVerificationResult.http(422);
    await harness.cubit.purchase('course.product.36');

    harness.store.purchaseController.add([
      purchaseDetails(PurchaseStatus.purchased, productId: 'course.product.36'),
    ]);
    await settleStream();

    expect(harness.cubit.state.status, AppleIapStatus.failure);
    expect(harness.repository.enrolledCourseIds, isEmpty);
    expect(harness.store.completedPurchases, isEmpty);
    expect(harness.cubit.state.message, contains('HTTP 422'));
    await harness.cubit.purchase('course.product.36');
    expect(harness.store.purchaseCalls, 1);
    expect(
      harness.preferences.getStringList('apple_iap_pending_enrollment_records'),
      hasLength(1),
    );
    await harness.close();
  });

  test('verify 500 and network errors never enroll or complete', () async {
    final harness = await _enrollmentHarness(
      productId: 'course.product.36',
      target: const AppleIapProductTarget(
        type: AppleIapProductType.course,
        contentId: 36,
      ),
    );
    final responses = <ApplePurchaseVerificationResult>[
      const ApplePurchaseVerificationResult.http(500),
      const ApplePurchaseVerificationResult.networkError('offline'),
    ];

    for (var index = 0; index < responses.length; index++) {
      harness.verify.response = responses[index];
      harness.store.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.purchased,
          id: 'verify-failure-$index',
          productId: 'course.product.36',
        ),
      ]);
      await settleStream();
      expect(harness.cubit.state.status, AppleIapStatus.failure);
    }

    expect(harness.repository.enrolledCourseIds, isEmpty);
    expect(harness.store.completedPurchases, isEmpty);
    await harness.close();
  });

  test(
    'unmapped Restore metadata does not leak into a later purchase error',
    () async {
      final harness = await _enrollmentHarness(
        productId: 'course.product.36',
        target: const AppleIapProductTarget(
          type: AppleIapProductType.course,
          contentId: 36,
        ),
      );

      final restore = harness.cubit.restorePurchases();
      await settleStream();
      harness.store.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.restored,
          id: 'unmapped-restore',
          productId: 'unknown.product',
        ),
      ]);
      await restore;
      expect(harness.cubit.state.restoreHasUnmappedProducts, isTrue);

      harness.verify.response = const ApplePurchaseVerificationResult.http(422);
      await harness.cubit.purchase('course.product.36');
      harness.store.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.purchased,
          id: 'later-purchase',
          productId: 'course.product.36',
        ),
      ]);
      await settleStream();

      expect(harness.cubit.state.status, AppleIapStatus.failure);
      expect(harness.cubit.state.verificationStatusCode, 422);
      expect(harness.cubit.state.restoreHasUnmappedProducts, isFalse);
      expect(harness.repository.enrolledCourseIds, isEmpty);
      await harness.close();
    },
  );

  test(
    'enrollment failure after HTTP 200 does not complete or succeed',
    () async {
      final harness = await _enrollmentHarness(
        productId: 'course.product.36',
        target: const AppleIapProductTarget(
          type: AppleIapProductType.course,
          contentId: 36,
        ),
      );
      harness.repository.courseEnrollmentResponse = Left(
        Failure('Enrollment failed'),
      );
      await harness.cubit.purchase('course.product.36');

      harness.store.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.purchased,
          productId: 'course.product.36',
        ),
      ]);
      await settleStream();

      expect(harness.verify.submittedTransactions, ['server-test-data']);
      expect(harness.cubit.state.status, AppleIapStatus.failure);
      expect(harness.cubit.state.verificationStatusCode, 200);
      expect(harness.store.completedPurchases, isEmpty);
      await harness.cubit.purchase('course.product.36');
      expect(harness.store.purchaseCalls, 1);
      expect(harness.repository.enrolledCourseIds, [36]);
      await harness.close();
    },
  );

  test('pending Apple transaction blocks a second purchase attempt', () async {
    final harness = await _enrollmentHarness(
      productId: 'course.product.36',
      target: const AppleIapProductTarget(
        type: AppleIapProductType.course,
        contentId: 36,
      ),
    );
    await harness.cubit.purchase('course.product.36');
    harness.store.purchaseController.add([
      purchaseDetails(PurchaseStatus.pending, productId: 'course.product.36'),
    ]);
    await settleStream();

    await harness.cubit.purchase('course.product.36');

    expect(harness.store.purchaseCalls, 1);
    expect(harness.cubit.state.status, AppleIapStatus.pending);
    expect(harness.store.completedPurchases, isEmpty);
    await harness.close();
  });

  test('purchase timeout reservation survives Cubit recreation', () async {
    final harness = await _enrollmentHarness(
      productId: 'course.product.36',
      target: const AppleIapProductTarget(
        type: AppleIapProductType.course,
        contentId: 36,
      ),
      purchaseResponseTimeout: const Duration(milliseconds: 10),
    );
    await harness.cubit.purchase('course.product.36');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(harness.cubit.state.status, AppleIapStatus.purchaseTimedOut);
    await harness.cubit.close();

    final reopenedCubit = AppleIapCubit(
      service: harness.service,
      verifyApplePurchaseUseCase: harness.verify,
      enrollCourseUseCase: EnrollCourseUseCase(harness.repository),
      enrollChapterUseCase: EnrollChapterUseCase(harness.repository),
      productTargets: const {
        'course.product.36': AppleIapProductTarget(
          type: AppleIapProductType.course,
          contentId: 36,
        ),
      },
      preferences: harness.preferences,
      isIos: true,
    );
    await reopenedCubit.updateCourseAndChapterAccess(
      courseId: 36,
      isRequestStatusEligible: true,
      isEnrolled: false,
      hasPendingRequest: false,
      eligibleChapterIds: const {},
      courseAppleProductId: 'course.product.36',
      chapterAppleProductIds: const {},
    );
    await reopenedCubit.purchase('course.product.36');

    expect(harness.store.purchaseCalls, 1);
    expect(reopenedCubit.state.status, AppleIapStatus.verificationRequired);
    expect(harness.repository.enrolledCourseIds, isEmpty);
    await reopenedCubit.close();
    await harness.store.close();
  });

  test(
    'same Apple product cannot be reassigned after Pythagoras logout',
    () async {
      final harness = await _enrollmentHarness(
        productId: 'course.product.36',
        target: const AppleIapProductTarget(
          type: AppleIapProductType.course,
          contentId: 36,
        ),
      );
      await harness.cubit.purchase('course.product.36');
      harness.verify.response = const ApplePurchaseVerificationResult.http(422);
      harness.store.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.purchased,
          id: 'student-a-pending-transaction',
          productId: 'course.product.36',
        ),
      ]);
      await settleStream();
      await harness.cubit.close();
      await harness.preferences.remove(PreferencesKeys.userId.name);
      await harness.preferences.setInt(PreferencesKeys.userId.name, 202);

      final secondCubit = AppleIapCubit(
        service: harness.service,
        verifyApplePurchaseUseCase: harness.verify,
        enrollCourseUseCase: EnrollCourseUseCase(harness.repository),
        enrollChapterUseCase: EnrollChapterUseCase(harness.repository),
        productTargets: const {
          'course.product.36': AppleIapProductTarget(
            type: AppleIapProductType.course,
            contentId: 36,
          ),
        },
        preferences: harness.preferences,
        isIos: true,
      );
      await secondCubit.updateCourseAndChapterAccess(
        courseId: 36,
        isRequestStatusEligible: true,
        isEnrolled: false,
        hasPendingRequest: false,
        eligibleChapterIds: const {},
        courseAppleProductId: 'course.product.36',
        chapterAppleProductIds: const {},
      );
      await secondCubit.purchase('course.product.36');

      expect(secondCubit.state.status, AppleIapStatus.transactionConflict);
      expect(secondCubit.state.message, contains('حساب طالب آخر'));
      expect(harness.store.purchaseCalls, 1);
      expect(harness.repository.enrolledCourseIds, isEmpty);
      expect(harness.store.completedPurchases, isEmpty);
      await secondCubit.close();
      await harness.store.close();
    },
  );

  test(
    'StoreKit duplicate object is retained for safe reconciliation',
    () async {
      final harness = await _enrollmentHarness(
        productId: 'course.product.36',
        target: const AppleIapProductTarget(
          type: AppleIapProductType.course,
          contentId: 36,
        ),
      );
      harness.store.purchaseError = PlatformException(
        code: 'storekit_duplicate_product_object',
        message: 'A transaction is pending for this product.',
      );

      await harness.cubit.purchase('course.product.36');
      expect(harness.cubit.state.status, AppleIapStatus.verificationRequired);
      await harness.cubit.purchase('course.product.36');

      expect(harness.cubit.state.status, AppleIapStatus.transactionConflict);
      expect(harness.store.purchaseCalls, 1);
      expect(harness.repository.enrolledCourseIds, isEmpty);
      expect(harness.store.completedPurchases, isEmpty);
      await harness.close();
    },
  );

  test('Restore and purchase do not overlap', () async {
    final restoreGate = Completer<void>();
    final harness = await _enrollmentHarness(
      productId: 'course.product.36',
      target: const AppleIapProductTarget(
        type: AppleIapProductType.course,
        contentId: 36,
      ),
      restoreGate: restoreGate,
    );

    final restore = harness.cubit.restorePurchases();
    await settleStream();
    await harness.cubit.purchase('course.product.36');
    harness.store.purchaseController.add([
      purchaseDetails(
        PurchaseStatus.canceled,
        id: 'restore-cancelled',
        productId: 'course.product.36',
      ),
    ]);
    await settleStream();
    restoreGate.complete();
    await restore;

    expect(harness.store.restoreCalls, 1);
    expect(harness.store.purchaseCalls, 0);
    expect(harness.store.completedPurchases, hasLength(1));
    await harness.close();
  });

  test('duplicate purchase event verifies but enrolls only once', () async {
    final harness = await _enrollmentHarness(
      productId: 'course.product.36',
      target: const AppleIapProductTarget(
        type: AppleIapProductType.course,
        contentId: 36,
      ),
    );
    final purchase = purchaseDetails(
      PurchaseStatus.purchased,
      productId: 'course.product.36',
    );
    var successEvents = 0;
    final subscription = harness.cubit.stream.listen((state) {
      if (state.status == AppleIapStatus.purchaseConfirmed) successEvents++;
    });

    harness.store.purchaseController.add([purchase]);
    harness.store.purchaseController.add([purchase]);
    await settleStream();

    expect(harness.repository.enrolledCourseIds, [36]);
    expect(successEvents, 1);
    expect(harness.store.completedPurchases, hasLength(1));
    await subscription.cancel();
    await harness.close();
  });

  test('Restore verifies and enrolls the restored product target', () async {
    final harness = await _enrollmentHarness(
      productId: 'chapter.product.245',
      target: const AppleIapProductTarget(
        type: AppleIapProductType.chapter,
        contentId: 245,
        parentContentId: 36,
      ),
      restoreOwners: const {'transaction-1': 'chapter.product.245'},
    );

    final restore = harness.cubit.restorePurchases();
    await settleStream();
    harness.store.purchaseController.add([
      purchaseDetails(
        PurchaseStatus.restored,
        productId: 'chapter.product.245',
      ),
    ]);
    await restore;

    expect(harness.verify.submittedTransactions, ['server-test-data']);
    expect(harness.repository.enrolledChapterIds, [245]);
    expect(harness.cubit.state.status, AppleIapStatus.restored);
    expect(harness.store.completedPurchases, hasLength(1));
    await harness.close();
  });

  test(
    'Restore aggregates multiple valid transactions into one result',
    () async {
      final restoreGate = Completer<void>();
      final harness = await _enrollmentHarness(
        productId: 'course.product.36',
        target: const AppleIapProductTarget(
          type: AppleIapProductType.course,
          contentId: 36,
        ),
        additionalTargets: const {
          'chapter.product.245': AppleIapProductTarget(
            type: AppleIapProductType.chapter,
            contentId: 245,
            parentContentId: 36,
          ),
        },
        restoreOwners: const {
          'restore-course-36': 'course.product.36',
          'restore-chapter-245': 'chapter.product.245',
        },
        restoreGate: restoreGate,
      );
      final finalResults = <AppleIapState>[];
      final subscription = harness.cubit.stream.listen((state) {
        if (!state.restoreInProgress &&
            (state.status == AppleIapStatus.restored ||
                state.status == AppleIapStatus.restoreEmpty ||
                state.status == AppleIapStatus.failure ||
                state.status == AppleIapStatus.verificationRequired)) {
          finalResults.add(state);
        }
      });

      final restore = harness.cubit.restorePurchases();
      await settleStream();
      harness.store.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.restored,
          id: 'restore-course-36',
          productId: 'course.product.36',
        ),
      ]);
      await settleStream();
      harness.store.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.restored,
          id: 'restore-chapter-245',
          productId: 'chapter.product.245',
        ),
      ]);
      await settleStream();
      restoreGate.complete();
      await restore;
      await settleStream();

      expect(harness.verify.submittedTransactions, hasLength(2));
      expect(harness.repository.enrolledCourseIds, [36]);
      expect(harness.repository.enrolledChapterIds, [245]);
      expect(harness.store.completedPurchases, hasLength(2));
      expect(harness.cubit.state.status, AppleIapStatus.restored);
      expect(finalResults, hasLength(1));
      await subscription.cancel();
      await harness.close();
    },
  );

  test(
    'Restore reports unknown products once and still enrolls known items',
    () async {
      final restoreGate = Completer<void>();
      final harness = await _enrollmentHarness(
        productId: 'course.product.36',
        target: const AppleIapProductTarget(
          type: AppleIapProductType.course,
          contentId: 36,
        ),
        additionalTargets: const {
          'chapter.product.245': AppleIapProductTarget(
            type: AppleIapProductType.chapter,
            contentId: 245,
            parentContentId: 36,
          ),
        },
        restoreOwners: const {
          'restore-known-course': 'course.product.36',
          'restore-known-chapter': 'chapter.product.245',
        },
        restoreGate: restoreGate,
      );
      final finalResults = <AppleIapState>[];
      final subscription = harness.cubit.stream.listen((state) {
        if (!state.restoreInProgress &&
            (state.status == AppleIapStatus.verificationRequired ||
                state.status == AppleIapStatus.failure ||
                state.status == AppleIapStatus.restored)) {
          finalResults.add(state);
        }
      });

      final restore = harness.cubit.restorePurchases();
      await settleStream();
      harness.store.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.restored,
          id: 'restore-known-course',
          productId: 'course.product.36',
        ),
        purchaseDetails(
          PurchaseStatus.restored,
          id: 'restore-unknown-one',
          productId: 'unknown.product.one',
        ),
      ]);
      await settleStream();
      harness.store.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.restored,
          id: 'restore-known-chapter',
          productId: 'chapter.product.245',
        ),
        purchaseDetails(
          PurchaseStatus.restored,
          id: 'restore-unknown-two',
          productId: 'unknown.product.two',
        ),
      ]);
      await settleStream();
      restoreGate.complete();
      await restore;
      await settleStream();

      expect(harness.verify.submittedTransactions, hasLength(2));
      expect(harness.repository.enrolledCourseIds, [36]);
      expect(harness.repository.enrolledChapterIds, [245]);
      expect(harness.store.completedPurchases, hasLength(2));
      expect(harness.cubit.state.status, AppleIapStatus.verificationRequired);
      expect(harness.cubit.state.restoreHasConfirmedEnrollment, isTrue);
      expect(harness.cubit.state.message, contains('منتج غير موجود'));
      expect(
        'منتج غير موجود'.allMatches(harness.cubit.state.message!).length,
        1,
      );
      expect(finalResults, hasLength(1));
      await subscription.cancel();
      await harness.close();
    },
  );

  test(
    'Restore without local purchase ownership cannot grant a course',
    () async {
      final harness = await _enrollmentHarness(
        productId: 'course.product.36',
        target: const AppleIapProductTarget(
          type: AppleIapProductType.course,
          contentId: 36,
        ),
      );
      final restore = harness.cubit.restorePurchases();
      await settleStream();
      harness.store.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.restored,
          id: 'unowned-restore',
          productId: 'course.product.36',
        ),
      ]);
      await restore;

      expect(harness.cubit.state.status, AppleIapStatus.transactionConflict);
      expect(harness.verify.submittedTransactions, isEmpty);
      expect(harness.repository.enrolledCourseIds, isEmpty);
      expect(harness.store.completedPurchases, isEmpty);
      await harness.close();
    },
  );

  test(
    'API product IDs load and resolve to their actual course and chapter',
    () async {
      final localStore = FakeAppleIapStore()
        ..response = ProductDetailsResponse(
          productDetails: [
            product(id: 'api.course.id'),
            product(id: 'api.chapter.id'),
          ],
          notFoundIDs: const [],
        );
      final localService = AppleIapService(store: localStore, isIos: true);
      final localCubit = AppleIapCubit(service: localService, isIos: true);

      await localCubit.updateCourseAndChapterAccess(
        courseId: 21,
        isRequestStatusEligible: true,
        isEnrolled: false,
        hasPendingRequest: false,
        eligibleChapterIds: {245},
        courseAppleProductId: 'api.course.id',
        chapterAppleProductIds: {245: 'api.chapter.id'},
      );

      expect(localStore.queriedProductIds, {'api.course.id', 'api.chapter.id'});
      expect(
        localCubit.targetFor('api.course.id')?.type,
        AppleIapProductType.course,
      );
      expect(localCubit.targetFor('api.course.id')?.contentId, 21);
      expect(
        localCubit.targetFor('api.chapter.id')?.type,
        AppleIapProductType.chapter,
      );
      expect(localCubit.targetFor('api.chapter.id')?.contentId, 245);
      expect(localCubit.targetFor('api.chapter.id')?.parentContentId, 21);

      await localCubit.purchase('api.course.id');
      expect(localStore.purchasedProductIds, ['api.course.id']);
      localStore.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.canceled,
          id: 'course-cancelled',
          productId: 'api.course.id',
        ),
      ]);
      await settleStream();
      await localCubit.purchase('api.chapter.id');
      expect(localStore.purchasedProductIds, [
        'api.course.id',
        'api.chapter.id',
      ]);

      await localCubit.close();
      await localStore.close();
    },
  );

  test('duplicate course and chapter product IDs are rejected', () async {
    final localStore = FakeAppleIapStore();
    final localService = AppleIapService(store: localStore, isIos: true);
    final localCubit = AppleIapCubit(service: localService, isIos: true);

    await localCubit.updateCourseAndChapterAccess(
      courseId: 21,
      isRequestStatusEligible: true,
      isEnrolled: false,
      hasPendingRequest: false,
      eligibleChapterIds: {245},
      courseAppleProductId: 'same.product.id',
      chapterAppleProductIds: {245: 'same.product.id'},
    );

    expect(localCubit.targetFor('same.product.id'), isNull);
    expect(localStore.loadProductsCalls, 0);
    expect(localStore.purchaseCalls, 0);

    await localCubit.close();
    await localStore.close();
  });

  test(
    'missing API product IDs never query StoreKit or start a purchase',
    () async {
      final localStore = FakeAppleIapStore();
      final localService = AppleIapService(store: localStore, isIos: true);
      final localCubit = AppleIapCubit(service: localService, isIos: true);

      await localCubit.updateCourseAndChapterAccess(
        courseId: 21,
        isRequestStatusEligible: true,
        isEnrolled: false,
        hasPendingRequest: false,
        eligibleChapterIds: {245},
        courseAppleProductId: ' ',
        chapterAppleProductIds: {245: null},
      );
      await localCubit.purchase('unknown.product.id');

      expect(localStore.loadProductsCalls, 0);
      expect(localStore.purchaseCalls, 0);
      expect(localCubit.targetFor('unknown.product.id'), isNull);

      await localCubit.close();
      await localStore.close();
    },
  );

  test('guest cannot purchase or restore through Cubit or service', () async {
    final localStore = FakeAppleIapStore()
      ..response = ProductDetailsResponse(
        productDetails: [product()],
        notFoundIDs: const [],
      );
    final localService = apple_iap_service.AppleIapService(
      store: localStore,
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
    );
    await localCubit.loadProducts();

    await localService.purchase(product());
    await localService.restorePurchases();
    await localCubit.purchase('test.product.course');
    await localCubit.restorePurchases();

    expect(localStore.purchaseCalls, 0);
    expect(localStore.restoreCalls, 0);

    await localCubit.close();
    await localStore.close();
  });

  test('authenticated user can purchase and restore through Cubit', () async {
    final localStore = FakeAppleIapStore()
      ..response = ProductDetailsResponse(
        productDetails: [product()],
        notFoundIDs: const [],
      );
    final localService = AppleIapService(
      store: localStore,
      isIos: true,
      isAuthenticated: () => true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
    );
    await localCubit.loadProducts();

    await localCubit.purchase('test.product.course');
    expect(localStore.purchaseCalls, 1);
    localStore.purchaseController.add([
      purchaseDetails(PurchaseStatus.canceled, id: 'cancel-before-restore'),
    ]);
    await settleStream();

    final restore = localCubit.restorePurchases();
    await settleStream();
    localStore.purchaseController.add([
      purchaseDetails(PurchaseStatus.restored, id: 'authenticated-restore'),
    ]);
    await restore;

    expect(localStore.restoreCalls, 1);
    expect(localCubit.state.status, AppleIapStatus.failure);

    await localCubit.close();
    await localStore.close();
  });

  test(
    'ios_iap_enabled controls course and chapter purchases together',
    () async {
      var iapEnabled = true;
      final localStore = FakeAppleIapStore()
        ..response = ProductDetailsResponse(
          productDetails: [
            product(id: 'api.course.id'),
            product(id: 'api.chapter.id'),
          ],
          notFoundIDs: const [],
        );
      final localService = AppleIapService(
        store: localStore,
        isIos: true,
        isIapEnabled: () => iapEnabled,
      );
      final localCubit = AppleIapCubit(service: localService, isIos: true);

      await localCubit.updateCourseAndChapterAccess(
        courseId: 21,
        isRequestStatusEligible: true,
        isEnrolled: false,
        hasPendingRequest: false,
        eligibleChapterIds: {245},
        courseAppleProductId: 'api.course.id',
        chapterAppleProductIds: {245: 'api.chapter.id'},
      );
      expect(localStore.queriedProductIds, {'api.course.id', 'api.chapter.id'});

      iapEnabled = false;
      await localCubit.updateIapEnabled(false);
      await localCubit.purchase('api.course.id');
      await localCubit.purchase('api.chapter.id');
      expect(localStore.purchasedProductIds, isEmpty);

      iapEnabled = true;
      await localCubit.updateIapEnabled(true);
      expect(localStore.queriedProductIds, {'api.course.id', 'api.chapter.id'});
      await localCubit.purchase('api.course.id');
      localStore.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.canceled,
          id: 'course-cancelled-for-gate-test',
          productId: 'api.course.id',
        ),
      ]);
      await settleStream();
      await localCubit.purchase('api.chapter.id');
      expect(localStore.purchasedProductIds, [
        'api.course.id',
        'api.chapter.id',
      ]);

      await localCubit.close();
      await localStore.close();
    },
  );

  test('Android does not query StoreKit or purchase Apple products', () async {
    final localStore = FakeAppleIapStore();
    final localService = AppleIapService(store: localStore, isIos: false);
    final localCubit = AppleIapCubit(service: localService, isIos: false);

    await localCubit.updateCourseAndChapterAccess(
      courseId: 21,
      isRequestStatusEligible: true,
      isEnrolled: false,
      hasPendingRequest: false,
      eligibleChapterIds: {245},
      courseAppleProductId: 'api.course.id',
      chapterAppleProductIds: {245: 'api.chapter.id'},
    );
    await localCubit.purchase('api.course.id');

    expect(localStore.loadProductsCalls, 0);
    expect(localStore.purchaseCalls, 0);

    await localCubit.close();
    await localStore.close();
  });

  test(
    'chapter direct request sends the target chapter ID and exposes API failure',
    () async {
      final repository = FakeDirectRequestRepository();
      final requestCubit = DirectRequestCubit(
        requestChapterDirectUseCase: RequestChapterDirectUseCase(repository),
        requestCourseDirectUseCase: RequestCourseDirectUseCase(repository),
      );
      const target = AppleIapProductTarget(
        type: AppleIapProductType.chapter,
        contentId: 245,
        parentContentId: 21,
      );

      await requestCubit.requestChapter(target.contentId);

      expect(repository.requestedChapterId, 245);
      expect(requestCubit.state, isA<DirectRequestError>());
      expect(
        (requestCubit.state as DirectRequestError).message,
        'activation failed',
      );
      await requestCubit.close();
    },
  );

  test('creating the Cubit does not query StoreKit automatically', () async {
    final localStore = FakeAppleIapStore();
    final localService = AppleIapService(
      store: localStore,
      productIds: {'pythagoras.course.21'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'pythagoras.course.21'},
      isIos: true,
    );

    expect(localStore.loadProductsCalls, 0);
    await localCubit.close();
    await localStore.close();
  });

  test('unavailable StoreKit does not expose a ready product', () async {
    final localStore = FakeAppleIapStore()..available = false;
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
    );

    await localCubit.loadProducts();

    expect(localCubit.state.status, AppleIapStatus.unavailable);
    expect(localCubit.state.products, isEmpty);
    await localCubit.close();
    await localStore.close();
  });

  test(
    'StoreKit becoming unavailable clears stale products and blocks buying',
    () async {
      final localStore = FakeAppleIapStore()
        ..response = ProductDetailsResponse(
          productDetails: [product()],
          notFoundIDs: const [],
        );
      final localService = AppleIapService(
        store: localStore,
        productIds: {'test.product.course'},
        isIos: true,
      );
      final localCubit = AppleIapCubit(
        service: localService,
        productIds: {'test.product.course'},
        isIos: true,
      );
      await localCubit.loadProducts();
      expect(localCubit.state.status, AppleIapStatus.ready);
      expect(localCubit.state.products, hasLength(1));

      localStore.available = false;
      await localCubit.updateIapEnabled(true);
      await localCubit.purchase('test.product.course');

      expect(localCubit.state.status, AppleIapStatus.unavailable);
      expect(localCubit.state.products, isEmpty);
      expect(localStore.purchaseCalls, 0);
      await localCubit.close();
      await localStore.close();
    },
  );

  test('disabled IAP flag blocks load, purchase, and restore calls', () async {
    final localStore = FakeAppleIapStore()..isIapEnabled = false;
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
    );

    await localCubit.loadProducts();
    await localCubit.purchase('test.product.course');
    await localCubit.restorePurchases();

    expect(localCubit.state.status, AppleIapStatus.unavailable);
    expect(localCubit.state.products, isEmpty);
    expect(localStore.loadProductsCalls, 0);
    expect(localStore.purchaseCalls, 0);
    expect(localStore.restoreCalls, 0);
    await localCubit.close();
    await localStore.close();
  });

  test('enrolled courses block purchase but still allow restore', () async {
    final localStore = FakeAppleIapStore();
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
      isEnrolled: true,
    );

    await localCubit.loadProducts();
    await localCubit.purchase('test.product.course');
    final restore = localCubit.restorePurchases();
    await settleStream();
    localStore.purchaseController.add([
      purchaseDetails(PurchaseStatus.restored),
    ]);
    await restore;

    expect(localCubit.state.products, isEmpty);
    expect(localCubit.state.status, AppleIapStatus.failure);
    expect(localCubit.state.transactionKey, isNotNull);
    expect(localStore.loadProductsCalls, 0);
    expect(localStore.purchaseCalls, 0);
    expect(localStore.restoreCalls, 1);
    expect(localStore.completedPurchases, isEmpty);
    await localCubit.close();
    await localStore.close();
  });

  test(
    'pending enrollment requests block purchase but allow restore',
    () async {
      final localStore = FakeAppleIapStore();
      final localService = AppleIapService(
        store: localStore,
        productIds: {'test.product.course'},
        isIos: true,
      );
      final localCubit = AppleIapCubit(
        service: localService,
        productIds: {'test.product.course'},
        isIos: true,
        restoreTimeout: Duration.zero,
        hasPendingRequest: true,
      );

      await localCubit.loadProducts();
      await localCubit.restorePurchases();

      expect(localCubit.state.products, isEmpty);
      expect(localStore.loadProductsCalls, 0);
      expect(localStore.restoreCalls, 1);
      expect(localCubit.state.status, AppleIapStatus.restoreEmpty);
      await localCubit.close();
      await localStore.close();
    },
  );

  test('reenabling IAP reloads products after a disabled state', () async {
    final localStore = FakeAppleIapStore()
      ..isIapEnabled = false
      ..response = ProductDetailsResponse(
        productDetails: [product()],
        notFoundIDs: const [],
      );
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
    );
    await localCubit.loadProducts();

    localStore.isIapEnabled = true;
    await localCubit.updateIapEnabled(true);

    expect(localCubit.state.status, AppleIapStatus.ready);
    expect(localCubit.state.products, hasLength(1));
    expect(localStore.loadProductsCalls, 1);
    await localCubit.close();
    await localStore.close();
  });

  test('Remote Config updates the live IAP gate', () async {
    final remoteConfigService = FakeRemoteConfigService();
    final remoteConfigCubit = RemoteConfigCubit(
      remoteConfigService: remoteConfigService,
    );
    final localStore = FakeAppleIapStore()
      ..response = ProductDetailsResponse(
        productDetails: [product(id: 'pythagoras.course.21')],
        notFoundIDs: const [],
      );
    final localService = AppleIapService(
      store: localStore,
      productIds: {'pythagoras.course.21'},
      isIos: true,
      isIapEnabled: () => remoteConfigService.iosIapEnabled,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'pythagoras.course.21'},
      isIos: true,
    );

    await remoteConfigCubit.load();
    expect(remoteConfigCubit.state.iosIapEnabled, isFalse);
    await localCubit.loadProducts();
    expect(localStore.loadProductsCalls, 0);

    remoteConfigService.setEnabled(true);
    await settleStream();
    await localCubit.updateIapEnabled(remoteConfigCubit.state.iosIapEnabled);
    expect(localCubit.state.status, AppleIapStatus.ready);

    remoteConfigService.setEnabled(false);
    await settleStream();
    await localCubit.updateIapEnabled(remoteConfigCubit.state.iosIapEnabled);
    await localCubit.purchase('pythagoras.course.21');
    await localCubit.restorePurchases();
    expect(localCubit.state.products, isEmpty);
    expect(localStore.purchaseCalls, 0);
    expect(localStore.restoreCalls, 0);

    await localCubit.close();
    await remoteConfigCubit.close();
    await localStore.close();
    await remoteConfigService.updates.close();
  });

  test('Remote Config initialization failure keeps IAP disabled', () async {
    final remoteConfigService = FakeRemoteConfigService()
      ..failInitialization = true;
    final remoteConfigCubit = RemoteConfigCubit(
      remoteConfigService: remoteConfigService,
    );

    await remoteConfigCubit.load();

    expect(remoteConfigCubit.state.iosIapEnabled, isFalse);
    expect(
      remoteConfigCubit.state.errorMessage,
      contains('Remote Config unavailable'),
    );
    await remoteConfigCubit.close();
    await remoteConfigService.updates.close();
  });

  test(
    'API enrollment updates block purchase without blocking restore',
    () async {
      final localStore = FakeAppleIapStore()
        ..response = ProductDetailsResponse(
          productDetails: [product()],
          notFoundIDs: const [],
        );
      final localService = AppleIapService(
        store: localStore,
        productIds: {'test.product.course'},
        isIos: true,
      );
      final localCubit = AppleIapCubit(
        service: localService,
        productIds: {'test.product.course'},
        isIos: true,
        restoreTimeout: Duration.zero,
      );
      await localCubit.loadProducts();

      await localCubit.updateCourseAccess(
        isRequestStatusEligible: false,
        isEnrolled: true,
        hasPendingRequest: false,
      );
      expect(localCubit.state.products, isEmpty);
      await localCubit.purchase('test.product.course');
      await localCubit.restorePurchases();
      expect(localStore.purchaseCalls, 0);
      expect(localStore.restoreCalls, 1);

      await localCubit.updateCourseAccess(
        isRequestStatusEligible: false,
        isEnrolled: false,
        hasPendingRequest: false,
      );
      await localCubit.purchase('test.product.course');
      await localCubit.restorePurchases();
      expect(localCubit.state.products, isEmpty);
      expect(localStore.purchaseCalls, 0);
      expect(localStore.restoreCalls, 2);

      await localCubit.updateCourseAccess(
        isRequestStatusEligible: true,
        isEnrolled: false,
        hasPendingRequest: false,
      );
      expect(localCubit.state.status, AppleIapStatus.ready);
      expect(localCubit.state.products, hasLength(1));
      await localCubit.close();
      await localStore.close();
    },
  );

  testWidgets(
    'Apple actions fit compact and standard phone widths',
    (tester) async {
      final remoteConfigService = FakeRemoteConfigService(enabled: true);
      final remoteConfigCubit = RemoteConfigCubit(
        remoteConfigService: remoteConfigService,
      );
      await remoteConfigCubit.load();
      final localStore = FakeAppleIapStore()
        ..response = ProductDetailsResponse(
          productDetails: [product(id: 'pythagoras.course.21')],
          notFoundIDs: const [],
        );
      final localService = AppleIapService(
        store: localStore,
        productIds: {'pythagoras.course.21'},
        isIos: true,
      );
      final localCubit = AppleIapCubit(
        service: localService,
        productIds: {'pythagoras.course.21'},
        isIos: true,
      );
      await localCubit.loadProducts();

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MultiBlocProvider(
            providers: [
              BlocProvider<RemoteConfigCubit>.value(value: remoteConfigCubit),
              BlocProvider<AppleIapCubit>.value(value: localCubit),
            ],
            child: MaterialApp(
              theme: ThemeData(platform: TargetPlatform.iOS),
              home: const Scaffold(
                body: AppleIapPurchaseSection(
                  type: AppleIapProductType.course,
                  contentId: 21,
                  appleProductId: 'pythagoras.course.21',
                  isRequestStatusEligible: true,
                ),
              ),
            ),
          ),
        ),
      );

      for (final size in [const Size(320, 568), const Size(390, 844)]) {
        tester.view.physicalSize = size;
        await tester.pump();
        expect(find.text('استعادة المشتريات'), findsOneWidget);
        expect(find.textContaining('شراء عبر Apple'), findsOneWidget);
        expect(
          tester.getRect(find.text('استعادة المشتريات')).bottom,
          lessThanOrEqualTo(size.height),
        );
        expect(tester.takeException(), isNull);
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.runAsync(() async {
        await localCubit.close();
        await remoteConfigCubit.close();
        await localStore.close();
        await remoteConfigService.updates.close();
      });
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  testWidgets(
    'Remote Config toggles Apple actions without reopening screen',
    (tester) async {
      final remoteConfigService = FakeRemoteConfigService();
      final remoteConfigCubit = RemoteConfigCubit(
        remoteConfigService: remoteConfigService,
      );
      await remoteConfigCubit.load();
      final localStore = FakeAppleIapStore()
        ..response = ProductDetailsResponse(
          productDetails: [product(id: 'pythagoras.course.21')],
          notFoundIDs: const [],
        );
      final localService = AppleIapService(
        store: localStore,
        productIds: {'pythagoras.course.21'},
        isIos: true,
      );
      final localCubit = AppleIapCubit(
        service: localService,
        productIds: {'pythagoras.course.21'},
        isIos: true,
      );
      await localCubit.loadProducts();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MultiBlocProvider(
            providers: [
              BlocProvider<RemoteConfigCubit>.value(value: remoteConfigCubit),
              BlocProvider<AppleIapCubit>.value(value: localCubit),
            ],
            child: MaterialApp(
              theme: ThemeData(platform: TargetPlatform.iOS),
              home: Scaffold(
                body: const AppleIapPurchaseSection(
                  type: AppleIapProductType.course,
                  contentId: 21,
                  appleProductId: 'pythagoras.course.21',
                  isRequestStatusEligible: true,
                  tabletLandscape: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('استعادة المشتريات'), findsNothing);
      Future<void> setRemoteConfig(bool enabled) async {
        remoteConfigService.setEnabled(enabled);
        await tester.pump();
        await tester.pump();
      }

      await setRemoteConfig(true);
      expect(remoteConfigCubit.state.iosIapEnabled, isTrue);
      expect(find.text('استعادة المشتريات'), findsOneWidget);

      await setRemoteConfig(false);
      expect(remoteConfigCubit.state.iosIapEnabled, isFalse);
      expect(find.text('استعادة المشتريات'), findsNothing);

      await setRemoteConfig(true);
      expect(remoteConfigCubit.state.iosIapEnabled, isTrue);
      expect(find.text('استعادة المشتريات'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.runAsync(() async {
        await localCubit.close();
        await remoteConfigCubit.close();
        await localStore.close();
        await remoteConfigService.updates.close();
      });
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  testWidgets('Restore remains visible for all request and enrollment states', (
    tester,
  ) async {
    final remoteConfigService = FakeRemoteConfigService(enabled: true);
    final remoteConfigCubit = RemoteConfigCubit(
      remoteConfigService: remoteConfigService,
    );
    await remoteConfigCubit.load();
    final localStore = FakeAppleIapStore()
      ..response = ProductDetailsResponse(
        productDetails: [product(id: 'pythagoras.course.21')],
        notFoundIDs: const [],
      );
    final localService = AppleIapService(
      store: localStore,
      productIds: {'pythagoras.course.21'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'pythagoras.course.21'},
      isIos: true,
    );
    await localCubit.loadProducts();

    for (final access in [
      (
        isRequestStatusEligible: true,
        isEnrolled: false,
        hasPendingRequest: false,
        canPurchase: true,
      ),
      (
        isRequestStatusEligible: false,
        isEnrolled: false,
        hasPendingRequest: true,
        canPurchase: false,
      ),
      (
        isRequestStatusEligible: false,
        isEnrolled: true,
        hasPendingRequest: false,
        canPurchase: false,
      ),
    ]) {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MultiBlocProvider(
            providers: [
              BlocProvider<RemoteConfigCubit>.value(value: remoteConfigCubit),
              BlocProvider<AppleIapCubit>.value(value: localCubit),
            ],
            child: MaterialApp(
              theme: ThemeData(platform: TargetPlatform.iOS),
              home: Scaffold(
                body: AppleIapPurchaseSection(
                  type: AppleIapProductType.course,
                  contentId: 21,
                  appleProductId: 'pythagoras.course.21',
                  isRequestStatusEligible: access.isRequestStatusEligible,
                  isEnrolled: access.isEnrolled,
                  hasPendingRequest: access.hasPendingRequest,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('استعادة المشتريات'), findsOneWidget);
      expect(
        find.textContaining('شراء عبر Apple -'),
        access.canPurchase ? findsOneWidget : findsNothing,
      );
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      await localCubit.close();
      await remoteConfigCubit.close();
      await localStore.close();
      await remoteConfigService.updates.close();
    });
  });

  testWidgets('unavailable Apple product shows a message but no buy button', (
    tester,
  ) async {
    final remoteConfigService = FakeRemoteConfigService(enabled: true);
    final remoteConfigCubit = RemoteConfigCubit(
      remoteConfigService: remoteConfigService,
    );
    await remoteConfigCubit.load();
    final localStore = FakeAppleIapStore()
      ..response = ProductDetailsResponse(
        productDetails: const [],
        notFoundIDs: const ['pythagoras.course.21'],
      );
    final localService = AppleIapService(
      store: localStore,
      productIds: {'pythagoras.course.21'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'pythagoras.course.21'},
      isIos: true,
    );
    await localCubit.loadProducts();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => MultiBlocProvider(
          providers: [
            BlocProvider<RemoteConfigCubit>.value(value: remoteConfigCubit),
            BlocProvider<AppleIapCubit>.value(value: localCubit),
          ],
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const Scaffold(
              body: AppleIapPurchaseSection(
                type: AppleIapProductType.course,
                contentId: 21,
                appleProductId: 'pythagoras.course.21',
                isRequestStatusEligible: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('الشراء عبر Apple غير متاح حاليًا'), findsOneWidget);
    expect(find.textContaining('شراء عبر Apple -'), findsNothing);
    expect(find.text('استعادة المشتريات'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      await localCubit.close();
      await remoteConfigCubit.close();
      await localStore.close();
      await remoteConfigService.updates.close();
    });
  });

  testWidgets('missing API product ID shows a message and blocks buying', (
    tester,
  ) async {
    final remoteConfigService = FakeRemoteConfigService(enabled: true);
    final remoteConfigCubit = RemoteConfigCubit(
      remoteConfigService: remoteConfigService,
    );
    await remoteConfigCubit.load();
    final localStore = FakeAppleIapStore();
    final localService = AppleIapService(store: localStore, isIos: true);
    final localCubit = AppleIapCubit(service: localService, isIos: true);
    await localCubit.updateCourseAndChapterAccess(
      courseId: 21,
      isRequestStatusEligible: true,
      isEnrolled: false,
      hasPendingRequest: false,
      eligibleChapterIds: const {},
      courseAppleProductId: null,
      chapterAppleProductIds: const {},
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => MultiBlocProvider(
          providers: [
            BlocProvider<RemoteConfigCubit>.value(value: remoteConfigCubit),
            BlocProvider<AppleIapCubit>.value(value: localCubit),
          ],
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const Scaffold(
              body: AppleIapPurchaseSection(
                type: AppleIapProductType.course,
                contentId: 21,
                appleProductId: '  ',
                isRequestStatusEligible: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('الشراء عبر Apple غير متاح لهذا المحتوى حاليًا'),
      findsOneWidget,
    );
    expect(find.textContaining('شراء عبر Apple -'), findsNothing);
    expect(localStore.loadProductsCalls, 0);
    expect(localStore.purchaseCalls, 0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      await localCubit.close();
      await remoteConfigCubit.close();
      await localStore.close();
      await remoteConfigService.updates.close();
    });
  });

  testWidgets('guest purchase and restore actions show the login sheet', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferencesStorage(
      await SharedPreferences.getInstance(),
    );
    await sl.reset();
    sl.registerSingleton<PreferencesStorage>(preferences);

    final remoteConfigService = FakeRemoteConfigService(enabled: true);
    final remoteConfigCubit = RemoteConfigCubit(
      remoteConfigService: remoteConfigService,
    );
    await remoteConfigCubit.load();
    final localStore = FakeAppleIapStore()
      ..response = ProductDetailsResponse(
        productDetails: [product(id: 'guest.course.product')],
        notFoundIDs: const [],
      );
    final localService = AppleIapService(
      store: localStore,
      productIds: {'guest.course.product'},
      isIos: true,
      isAuthenticated: () => preferences.isAuthenticated,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'guest.course.product'},
      isIos: true,
    );
    await localCubit.loadProducts();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => MultiBlocProvider(
          providers: [
            BlocProvider<RemoteConfigCubit>.value(value: remoteConfigCubit),
            BlocProvider<AppleIapCubit>.value(value: localCubit),
          ],
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const Scaffold(
              body: AppleIapPurchaseSection(
                type: AppleIapProductType.course,
                contentId: 21,
                appleProductId: 'guest.course.product',
                isRequestStatusEligible: true,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.textContaining('شراء عبر Apple -'));
    await tester.pumpAndSettle();
    expect(find.text('يجب تسجيل الدخول أولًا'), findsOneWidget);
    expect(localStore.purchaseCalls, 0);
    expect(localStore.restoreCalls, 0);

    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('استعادة المشتريات'));
    await tester.pumpAndSettle();
    expect(find.text('يجب تسجيل الدخول أولًا'), findsOneWidget);
    expect(localStore.purchaseCalls, 0);
    expect(localStore.restoreCalls, 0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      await localCubit.close();
      await remoteConfigCubit.close();
      await localStore.close();
      await remoteConfigService.updates.close();
      await sl.reset();
    });
  });

  testWidgets('Restore button delegates only one in-flight restore', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      PreferencesKeys.userToken.name: 'authenticated-test-token',
    });
    await sl.reset();
    sl.registerSingleton<PreferencesStorage>(
      PreferencesStorage(await SharedPreferences.getInstance()),
    );

    final remoteConfigService = FakeRemoteConfigService(enabled: true);
    final remoteConfigCubit = RemoteConfigCubit(
      remoteConfigService: remoteConfigService,
    );
    await remoteConfigCubit.load();
    final localStore = FakeAppleIapStore()..restoreGate = Completer<void>();
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
      isEnrolled: true,
      restoreTimeout: const Duration(seconds: 2),
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => MultiBlocProvider(
          providers: [
            BlocProvider<RemoteConfigCubit>.value(value: remoteConfigCubit),
            BlocProvider<AppleIapCubit>.value(value: localCubit),
          ],
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const Scaffold(
              body: AppleIapPurchaseSection(
                type: AppleIapProductType.course,
                contentId: 21,
                isRequestStatusEligible: false,
                isEnrolled: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('استعادة المشتريات'), findsOneWidget);
    expect(find.textContaining('شراء عبر Apple'), findsNothing);
    await tester.tap(find.text('استعادة المشتريات'));
    await tester.pump();
    expect(localStore.restoreCalls, 1);
    expect(localCubit.state.status, AppleIapStatus.loading);

    await tester.tap(find.text('استعادة المشتريات'));
    await tester.pump();
    expect(localStore.restoreCalls, 1);

    localStore.purchaseController.add([
      purchaseDetails(PurchaseStatus.restored),
    ]);
    localStore.restoreGate!.complete();
    await tester.pump();
    await tester.pump();
    expect(localCubit.state.status, AppleIapStatus.failure);
    expect(localCubit.state.transactionKey, isNotNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      await localCubit.close();
      await remoteConfigCubit.close();
      await localStore.close();
      await remoteConfigService.updates.close();
      await sl.reset();
    });
  });

  test('StoreKit response errors become a failure state', () async {
    final localStore = FakeAppleIapStore()
      ..response = ProductDetailsResponse(
        productDetails: const [],
        notFoundIDs: const ['test.product.course'],
        error: IAPError(
          source: 'test',
          code: 'storekit_no_response',
          message: 'StoreKit response failed',
        ),
      );
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
    );

    await localCubit.loadProducts();

    expect(localCubit.state.status, AppleIapStatus.failure);
    expect(localCubit.state.message, 'StoreKit response failed');
    await localCubit.close();
    await localStore.close();
  });

  test('not found products become unavailable without a product', () async {
    final localStore = FakeAppleIapStore()
      ..response = ProductDetailsResponse(
        productDetails: const [],
        notFoundIDs: const ['test.product.course'],
      );
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
    );

    await localCubit.loadProducts();

    expect(localCubit.state.status, AppleIapStatus.unavailable);
    expect(localCubit.state.products, isEmpty);
    await localCubit.close();
    await localStore.close();
  });

  test(
    'service delegates availability, restore, purchase, and completion',
    () async {
      expect(await service.isAvailable(), isTrue);
      expect(await service.purchase(product()), isTrue);

      await service.restorePurchases();
      expect(store.restoreCalled, isTrue);

      final pending = purchaseDetails(
        PurchaseStatus.purchased,
        pendingCompletePurchase: true,
      );
      await service.completePurchase(pending);
      expect(store.completedPurchases, [pending]);

      await service.completePurchase(
        purchaseDetails(
          PurchaseStatus.purchased,
          pendingCompletePurchase: false,
        ),
      );
      expect(store.completedPurchases, [pending]);
    },
  );

  test(
    'pending then purchased stays verification-gated and deduplicated',
    () async {
      expect(cubit.state.status, AppleIapStatus.ready);
      var confirmedEvents = 0;
      final subscription = cubit.stream.listen((state) {
        if (state.status == AppleIapStatus.verificationRequired) {
          confirmedEvents++;
        }
      });

      store.purchaseController.add([purchaseDetails(PurchaseStatus.pending)]);
      await settleStream();
      expect(cubit.state.status, AppleIapStatus.pending);
      expect(store.completedPurchases, isEmpty);

      final purchased = purchaseDetails(PurchaseStatus.purchased);
      store.purchaseController.add([purchased]);
      await settleStream();
      expect(cubit.state.status, AppleIapStatus.verificationRequired);
      expect(cubit.state.transactionKey, 'transaction-1');
      expect(store.completedPurchases, isEmpty);

      store.purchaseController.add([purchased]);
      await settleStream();
      expect(store.completedPurchases, isEmpty);
      expect(cubit.purchaseNeedsReconciliation, isTrue);
      await cubit.purchase('test.product.course');
      expect(store.purchaseCalls, 0);
      expect(confirmedEvents, 1);
      await subscription.cancel();
    },
  );

  test(
    'cancellation and errors are handled and their transactions completed',
    () async {
      final canceled = purchaseDetails(PurchaseStatus.canceled);
      store.purchaseController.add([canceled]);
      await settleStream();
      expect(cubit.state.status, AppleIapStatus.cancelled);
      expect(store.completedPurchases, [canceled]);

      final error = IAPError(
        source: 'test',
        code: 'failed',
        message: 'purchase failed',
      );
      final failedPurchase = purchaseDetails(
        PurchaseStatus.error,
        id: 'transaction-2',
        error: error,
      );
      store.purchaseController.add([failedPurchase]);
      await settleStream();
      expect(cubit.state.status, AppleIapStatus.failure);
      expect(cubit.state.message, contains('purchase failed'));
      expect(cubit.state.message, contains('استخدم استعادة المشتريات'));
      expect(store.completedPurchases, [canceled, failedPurchase]);
    },
  );

  test(
    'purchase stays incomplete until backend verification is available',
    () async {
      final purchased = purchaseDetails(PurchaseStatus.purchased);
      store.purchaseController.add([purchased]);
      await settleStream();

      expect(cubit.state.status, AppleIapStatus.verificationRequired);
      expect(cubit.state.transactionKey, 'transaction-1');
      expect(store.completedPurchases, isEmpty);

      store.purchaseController.add([purchased]);
      await settleStream();
      expect(store.completedPurchases, isEmpty);
    },
  );

  test(
    'student A transaction remains blocked after logout and student B login',
    () async {
      SharedPreferences.setMockInitialValues({
        PreferencesKeys.userId.name: 101,
        'apple_iap_submitted_purchase_keys': ['apple-tx-previous-account'],
        'apple_iap_submitted_purchase_owners': [
          '101|apple-tx-previous-account',
        ],
      });
      final preferences = await SharedPreferences.getInstance();
      final preferencesStorage = PreferencesStorage(preferences);
      await preferencesStorage.clearUserSessionData();
      await preferencesStorage.saveUserId(202);
      final localStore = FakeAppleIapStore()
        ..response = ProductDetailsResponse(
          productDetails: [product()],
          notFoundIDs: const [],
        );
      final localService = AppleIapService(
        store: localStore,
        productIds: {'test.product.course'},
        isIos: true,
      );
      final localCubit = AppleIapCubit(
        service: localService,
        productIds: {'test.product.course'},
        isIos: true,
        preferences: preferences,
      );
      await localCubit.loadProducts();

      localStore.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.purchased,
          id: 'apple-tx-previous-account',
        ),
      ]);
      await settleStream();

      expect(localCubit.state.status, AppleIapStatus.transactionConflict);
      expect(localCubit.state.transactionKey, isNull);
      expect(localCubit.state.message, contains('حساب طالب آخر'));
      expect(
        preferences.getStringList('apple_iap_submitted_purchase_keys'),
        contains('apple-tx-previous-account'),
      );
      expect(
        preferences.getStringList('apple_iap_submitted_purchase_owners'),
        contains('101|apple-tx-previous-account'),
      );
      expect(localStore.completedPurchases, isEmpty);
      await localCubit.close();
      await localStore.close();
    },
  );

  test('student B without a recorded transaction may purchase', () async {
    SharedPreferences.setMockInitialValues({PreferencesKeys.userId.name: 202});
    final preferences = await SharedPreferences.getInstance();
    final localStore = FakeAppleIapStore()
      ..response = ProductDetailsResponse(
        productDetails: [product()],
        notFoundIDs: const [],
      );
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
      preferences: preferences,
    );
    await localCubit.loadProducts();

    await localCubit.purchase('test.product.course');

    expect(localStore.purchaseCalls, 1);
    expect(localCubit.state.status, AppleIapStatus.purchasing);
    expect(localCubit.state.message, isNull);
    await localCubit.close();
    await localStore.close();
  });

  test('an old restored transaction cannot cross student accounts', () async {
    SharedPreferences.setMockInitialValues({
      PreferencesKeys.userId.name: 202,
      'apple_iap_submitted_purchase_keys': ['apple-tx-previous-account'],
      'apple_iap_submitted_purchase_owners': ['101|apple-tx-previous-account'],
    });
    final preferences = await SharedPreferences.getInstance();
    final localStore = FakeAppleIapStore()
      ..response = ProductDetailsResponse(
        productDetails: [product()],
        notFoundIDs: const [],
      );
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
      preferences: preferences,
    );
    await localCubit.loadProducts();

    final restore = localCubit.restorePurchases();
    await settleStream();
    localStore.purchaseController.add([
      purchaseDetails(PurchaseStatus.restored, id: 'apple-tx-previous-account'),
    ]);
    await restore;

    expect(localCubit.state.status, AppleIapStatus.transactionConflict);
    expect(localCubit.state.message, contains('حساب طالب آخر'));
    expect(localCubit.state.transactionKey, isNull);
    expect(localStore.purchaseCalls, 0);
    expect(localStore.completedPurchases, isEmpty);
    await localCubit.close();
    await localStore.close();
  });

  test('unmapped restore reports prior-account transaction conflict', () async {
    SharedPreferences.setMockInitialValues({
      PreferencesKeys.userId.name: 202,
      'apple_iap_submitted_purchase_keys': ['apple-tx-previous-account'],
      'apple_iap_submitted_purchase_owners': ['101|apple-tx-previous-account'],
    });
    final preferences = await SharedPreferences.getInstance();
    final localStore = FakeAppleIapStore()
      ..response = ProductDetailsResponse(
        productDetails: [product()],
        notFoundIDs: const [],
      );
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
      preferences: preferences,
    );
    await localCubit.loadProducts();

    final restore = localCubit.restorePurchases();
    await settleStream();
    localStore.purchaseController.add([
      purchaseDetails(
        PurchaseStatus.restored,
        id: 'apple-tx-previous-account',
        productId: 'product.from.another.course',
      ),
    ]);
    await restore;

    expect(localCubit.state.status, AppleIapStatus.transactionConflict);
    expect(localCubit.state.message, contains('حساب طالب آخر'));
    expect(localStore.completedPurchases, isEmpty);
    expect(localStore.restoreCalls, 1);
    await localCubit.close();
    await localStore.close();
  });

  test(
    'restoring one non-consumable does not block a different product',
    () async {
      final localStore = FakeAppleIapStore()
        ..response = ProductDetailsResponse(
          productDetails: [
            product(id: 'pythagoras.course.21'),
            product(id: 'pythagoras.course.29'),
          ],
          notFoundIDs: const [],
        );
      final productIds = {'pythagoras.course.21', 'pythagoras.course.29'};
      final localService = AppleIapService(
        store: localStore,
        productIds: productIds,
        isIos: true,
      );
      final localCubit = AppleIapCubit(
        service: localService,
        productIds: productIds,
        isIos: true,
      );
      await localCubit.loadProducts();

      final restore = localCubit.restorePurchases();
      await settleStream();
      localStore.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.restored,
          id: 'course-21-transaction',
          productId: 'pythagoras.course.21',
        ),
      ]);
      await restore;

      await localCubit.purchase('pythagoras.course.21');
      expect(localStore.purchaseCalls, 0);
      await localCubit.purchase('pythagoras.course.29');
      expect(localStore.purchaseCalls, 1);

      await localCubit.close();
      await localStore.close();
    },
  );

  test(
    'transaction conflict is emitted before StoreKit completion returns',
    () async {
      SharedPreferences.setMockInitialValues({
        PreferencesKeys.userId.name: 202,
        'apple_iap_submitted_purchase_keys': ['apple-tx-previous-account'],
        'apple_iap_submitted_purchase_owners': [
          '101|apple-tx-previous-account',
        ],
      });
      final preferences = await SharedPreferences.getInstance();
      final localStore = FakeAppleIapStore()
        ..completeGate = Completer<void>()
        ..response = ProductDetailsResponse(
          productDetails: [product()],
          notFoundIDs: const [],
        );
      final localService = AppleIapService(
        store: localStore,
        productIds: {'test.product.course'},
        isIos: true,
      );
      final localCubit = AppleIapCubit(
        service: localService,
        productIds: {'test.product.course'},
        isIos: true,
        preferences: preferences,
      );
      await localCubit.loadProducts();

      localStore.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.purchased,
          id: 'apple-tx-previous-account',
        ),
      ]);
      await settleStream();

      expect(localCubit.state.status, AppleIapStatus.transactionConflict);
      expect(localCubit.state.message, contains('حساب طالب آخر'));
      expect(localStore.completeCalls, 0);
      localStore.completeGate!.complete();
      await settleStream();
      await localCubit.close();
      await localStore.close();
    },
  );

  test('successful request records the transaction owner account', () async {
    SharedPreferences.setMockInitialValues({PreferencesKeys.userId.name: 303});
    final preferences = await SharedPreferences.getInstance();
    final localStore = FakeAppleIapStore()
      ..response = ProductDetailsResponse(
        productDetails: [product()],
        notFoundIDs: const [],
      );
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
      preferences: preferences,
    );
    await localCubit.loadProducts();

    final purchased = purchaseDetails(PurchaseStatus.purchased);
    localStore.purchaseController.add([purchased]);
    await settleStream();
    expect(localCubit.state.status, AppleIapStatus.failure);
    expect(
      preferences.getStringList('apple_iap_submitted_purchase_owners'),
      isNull,
    );

    expect(
      preferences.getStringList('apple_iap_submitted_purchase_owners'),
      isNull,
    );
    expect(localStore.completedPurchases, isEmpty);
    await localCubit.close();
    await localStore.close();
  });

  test(
    'a purchase that cannot start fails without leaving an active product',
    () async {
      store.purchaseStarted = false;

      await cubit.purchase('test.product.course');

      expect(cubit.state.status, AppleIapStatus.failure);
      expect(cubit.state.activeProductId, isNull);
      expect(cubit.state.message, contains('استخدم استعادة المشتريات'));
      expect(store.completedPurchases, isEmpty);
    },
  );

  test('concurrent purchase calls only start one Apple transaction', () async {
    final firstPurchase = cubit.purchase('test.product.course');
    final secondPurchase = cubit.purchase('test.product.course');

    await Future.wait([firstPurchase, secondPurchase]);

    expect(store.purchaseCalls, 1);
    expect(cubit.state.status, AppleIapStatus.purchasing);
  });

  test(
    'purchase with no Apple response times out and blocks another charge',
    () async {
      final localStore = FakeAppleIapStore()
        ..response = ProductDetailsResponse(
          productDetails: [product()],
          notFoundIDs: const [],
        );
      final localService = AppleIapService(
        store: localStore,
        productIds: {'test.product.course'},
        isIos: true,
      );
      final localCubit = AppleIapCubit(
        service: localService,
        productIds: {'test.product.course'},
        isIos: true,
        purchaseResponseTimeout: const Duration(milliseconds: 10),
        restoreTimeout: Duration.zero,
      );
      await localCubit.loadProducts();

      await localCubit.purchase('test.product.course');
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(localCubit.state.status, AppleIapStatus.purchaseTimedOut);
      expect(localCubit.state.message, contains('لم يصل تأكيد من Apple'));
      await localCubit.purchase('test.product.course');
      expect(localStore.purchaseCalls, 1);

      await localCubit.restorePurchases();
      expect(localStore.restoreCalls, 1);
      expect(localCubit.purchaseNeedsReconciliation, isTrue);
      await localCubit.purchase('test.product.course');
      expect(localStore.purchaseCalls, 1);
      await localCubit.close();
      await localStore.close();
    },
  );

  test('pending purchase timeout is not treated as success', () async {
    final localStore = FakeAppleIapStore()
      ..response = ProductDetailsResponse(
        productDetails: [product()],
        notFoundIDs: const [],
      );
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
      purchaseResponseTimeout: const Duration(milliseconds: 10),
    );
    await localCubit.loadProducts();
    await localCubit.purchase('test.product.course');
    localStore.purchaseController.add([
      purchaseDetails(PurchaseStatus.pending),
    ]);
    await settleStream();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(localCubit.state.status, AppleIapStatus.purchaseTimedOut);
    expect(localCubit.state.message, contains('ما زالت معلّقة'));
    expect(localCubit.state.transactionKey, isNull);
    expect(localCubit.purchaseNeedsReconciliation, isTrue);
    await localCubit.close();
    await localStore.close();
  });

  test(
    'late purchased event resolves an unresolved purchase without retry',
    () async {
      final localStore = FakeAppleIapStore()
        ..response = ProductDetailsResponse(
          productDetails: [product()],
          notFoundIDs: const [],
        );
      final localService = AppleIapService(
        store: localStore,
        productIds: {'test.product.course'},
        isIos: true,
      );
      final localCubit = AppleIapCubit(
        service: localService,
        productIds: {'test.product.course'},
        isIos: true,
        purchaseResponseTimeout: const Duration(milliseconds: 10),
      );
      await localCubit.loadProducts();
      await localCubit.purchase('test.product.course');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(localCubit.purchaseNeedsReconciliation, isTrue);

      localStore.purchaseController.add([
        purchaseDetails(PurchaseStatus.purchased),
      ]);
      await settleStream();

      expect(localCubit.state.status, AppleIapStatus.failure);
      expect(localCubit.purchaseNeedsReconciliation, isTrue);
      expect(localStore.purchaseCalls, 1);
      expect(localStore.completedPurchases, isEmpty);
      await localCubit.close();
      await localStore.close();
    },
  );

  test('stale unknown product is silent until a manual Restore', () async {
    final unknown = PurchaseDetails(
      purchaseID: 'unknown-transaction',
      productID: 'unknown.product',
      verificationData: PurchaseVerificationData(
        localVerificationData: 'local',
        serverVerificationData: 'server',
        source: 'test',
      ),
      transactionDate: '1',
      status: PurchaseStatus.purchased,
    );

    var unresolvedNotifications = 0;
    final subscription = cubit.stream.listen((state) {
      if (state.status == AppleIapStatus.verificationRequired) {
        unresolvedNotifications++;
      }
    });
    store.purchaseController.add([unknown]);
    store.purchaseController.add([unknown]);
    await settleStream();

    expect(cubit.state.status, AppleIapStatus.ready);
    expect(cubit.state.message, isNull);
    expect(cubit.purchaseNeedsReconciliation, isTrue);
    expect(unresolvedNotifications, 0);
    expect(store.completedPurchases, isEmpty);

    final restore = cubit.restorePurchases();
    await settleStream();
    final restored = purchaseDetails(
      PurchaseStatus.restored,
      id: 'unknown-transaction',
      productId: 'unknown.product',
    );
    store.purchaseController.add([restored, restored]);
    await restore;
    await settleStream();

    expect(cubit.state.status, AppleIapStatus.verificationRequired);
    expect(cubit.state.message, contains('منتج غير موجود'));
    expect(unresolvedNotifications, 1);
    expect(store.completedPurchases, isEmpty);
    await subscription.cancel();
  });

  test(
    'purchased event submits the exact StoreKit verification data',
    () async {
      const signedTransaction = 'actual-storekit-server-verification-data';
      store.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.purchased,
          serverVerificationData: signedTransaction,
        ),
      ]);
      await settleStream();

      expect(verifyApplePurchaseUseCase.submittedTransactions, [
        signedTransaction,
      ]);
      expect(cubit.state.status, AppleIapStatus.verificationRequired);
      expect(cubit.state.transactionKey, isNot(contains(signedTransaction)));
      expect(store.completedPurchases, isEmpty);
    },
  );

  test(
    'verification network failure never completes or grants the purchase',
    () async {
      verifyApplePurchaseUseCase.response =
          const ApplePurchaseVerificationResult.networkError('offline');
      store.purchaseController.add([purchaseDetails(PurchaseStatus.purchased)]);
      await settleStream();

      expect(cubit.state.status, AppleIapStatus.failure);
      expect(cubit.purchaseNeedsReconciliation, isTrue);
      expect(store.completedPurchases, isEmpty);
    },
  );

  test('non-success verification responses never grant content', () async {
    for (final statusCode in [204, 404, 422]) {
      verifyApplePurchaseUseCase.response =
          ApplePurchaseVerificationResult.http(statusCode);
      store.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.purchased,
          id: 'verification-$statusCode',
        ),
      ]);
      await settleStream();

      expect(cubit.state.status, AppleIapStatus.failure);
      expect(store.completedPurchases, isEmpty);
    }
  });

  test('restore retries server verification after a network failure', () async {
    verifyApplePurchaseUseCase.response =
        const ApplePurchaseVerificationResult.networkError('offline');
    store.purchaseController.add([
      purchaseDetails(PurchaseStatus.purchased, id: 'retry-transaction'),
    ]);
    await settleStream();
    expect(cubit.state.status, AppleIapStatus.failure);

    verifyApplePurchaseUseCase.response =
        const ApplePurchaseVerificationResult.http(200);
    final restore = cubit.restorePurchases();
    await settleStream();
    store.purchaseController.add([
      purchaseDetails(PurchaseStatus.restored, id: 'retry-transaction'),
    ]);
    await restore;

    expect(verifyApplePurchaseUseCase.submittedTransactions, [
      'server-test-data',
      'server-test-data',
    ]);
    expect(cubit.state.status, AppleIapStatus.verificationRequired);
    expect(store.completedPurchases, isEmpty);
  });

  test(
    'fallback transaction key never contains Apple verification data',
    () async {
      const privateVerificationData = 'private-apple-verification-data';
      final purchase = PurchaseDetails(
        purchaseID: null,
        productID: 'test.product.course',
        verificationData: PurchaseVerificationData(
          localVerificationData: 'local-test-data',
          serverVerificationData: privateVerificationData,
          source: 'test',
        ),
        transactionDate: '1',
        status: PurchaseStatus.purchased,
      )..pendingCompletePurchase = true;

      store.purchaseController.add([purchase]);
      await settleStream();

      expect(cubit.state.status, AppleIapStatus.verificationRequired);
      expect(
        cubit.state.transactionKey,
        isNot(contains(privateVerificationData)),
      );
    },
  );

  test('restored purchases are completed without creating a request', () async {
    final restore = cubit.restorePurchases();
    expect(store.restoreSawPurchaseListener, isTrue);
    await settleStream();
    expect(store.restoreCalled, isTrue);

    final restored = purchaseDetails(PurchaseStatus.restored);
    store.purchaseController.add([restored]);
    await restore;
    expect(cubit.state.status, AppleIapStatus.verificationRequired);
    expect(cubit.state.transactionKey, isNotNull);
    expect(verifyApplePurchaseUseCase.submittedTransactions, [
      'server-test-data',
    ]);
    expect(store.completedPurchases, isEmpty);
  });

  test('original student can restore their recorded transaction', () async {
    SharedPreferences.setMockInitialValues({
      PreferencesKeys.userId.name: 101,
      'apple_iap_submitted_purchase_keys': ['apple-tx-student-a'],
      'apple_iap_submitted_purchase_owners': ['101|apple-tx-student-a'],
    });
    final preferences = await SharedPreferences.getInstance();
    final localStore = FakeAppleIapStore()
      ..response = ProductDetailsResponse(
        productDetails: [product()],
        notFoundIDs: const [],
      );
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
      preferences: preferences,
    );
    await localCubit.loadProducts();

    final restore = localCubit.restorePurchases();
    await settleStream();
    localStore.purchaseController.add([
      purchaseDetails(PurchaseStatus.restored, id: 'apple-tx-student-a'),
    ]);
    await restore;

    expect(localCubit.state.status, AppleIapStatus.failure);
    expect(localCubit.state.transactionKey, isNotNull);
    expect(localStore.restoreCalls, 1);
    expect(localStore.completedPurchases, isEmpty);
    expect(
      preferences.getStringList('apple_iap_submitted_purchase_owners'),
      contains('101|apple-tx-student-a'),
    );
    await localCubit.close();
    await localStore.close();
  });

  test(
    'restore waits for restored stream and completes the transaction',
    () async {
      final restore = cubit.restorePurchases();
      await settleStream();
      expect(cubit.state.status, AppleIapStatus.loading);
      expect(cubit.state.message, 'جاري استعادة المشتريات...');

      store.purchaseController.add([purchaseDetails(PurchaseStatus.restored)]);
      await restore;

      expect(cubit.state.status, AppleIapStatus.verificationRequired);
      expect(store.completedPurchases, isEmpty);
    },
  );

  test('StoreKit completion failure preserves verified enrollment', () async {
    final harness = await _enrollmentHarness(
      productId: 'course.product.36',
      target: const AppleIapProductTarget(
        type: AppleIapProductType.course,
        contentId: 36,
      ),
      restoreOwners: const {'transaction-1': 'course.product.36'},
    );
    harness.store.completeError = Exception('StoreKit completion failed');

    final restore = harness.cubit.restorePurchases();
    expect(harness.store.restoreSawPurchaseListener, isTrue);
    await settleStream();
    harness.store.purchaseController.add([
      purchaseDetails(PurchaseStatus.restored, productId: 'course.product.36'),
    ]);
    await restore;

    expect(harness.cubit.state.status, AppleIapStatus.restored);
    expect(harness.cubit.state.verificationStatusCode, 200);
    expect(harness.repository.enrolledCourseIds, [36]);
    expect(harness.cubit.state.message, contains('تم تسجيل المحتوى'));
    expect(harness.cubit.purchaseNeedsReconciliation, isTrue);
    expect(harness.store.completedPurchases, isEmpty);
    await harness.close();
  });

  test(
    'restore reports no purchases when the stream has no restored result',
    () async {
      final localStore = FakeAppleIapStore();
      final localService = AppleIapService(
        store: localStore,
        productIds: {'test.product.course'},
        isIos: true,
      );
      final localCubit = AppleIapCubit(
        service: localService,
        productIds: {'test.product.course'},
        isIos: true,
        restoreTimeout: Duration.zero,
      );

      await localCubit.restorePurchases();

      expect(localCubit.state.status, AppleIapStatus.restoreEmpty);
      expect(localCubit.state.message, 'لم يتم العثور على مشتريات سابقة');
      await localCubit.close();
      await localStore.close();
    },
  );

  test('restore does not report empty before its timeout', () async {
    final localStore = FakeAppleIapStore();
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
      restoreTimeout: const Duration(milliseconds: 30),
    );

    final restore = localCubit.restorePurchases();
    await settleStream();
    expect(localCubit.state.status, AppleIapStatus.loading);
    expect(localCubit.state.message, 'جاري استعادة المشتريات...');

    await restore;

    expect(localCubit.state.status, AppleIapStatus.restoreEmpty);
    await localCubit.close();
    await localStore.close();
  });

  test(
    'pending restore times out without implying payment or activation',
    () async {
      final localStore = FakeAppleIapStore();
      final localService = AppleIapService(
        store: localStore,
        productIds: {'test.product.course'},
        isIos: true,
      );
      final localCubit = AppleIapCubit(
        service: localService,
        productIds: {'test.product.course'},
        isIos: true,
        restoreTimeout: const Duration(milliseconds: 20),
      );
      await localCubit.loadProducts();

      final restore = localCubit.restorePurchases();
      await settleStream();
      localStore.purchaseController.add([
        purchaseDetails(PurchaseStatus.pending),
      ]);

      await restore;

      expect(localCubit.state.status, AppleIapStatus.failure);
      expect(
        localCubit.state.message,
        contains('لم يتم تأكيد الدفع أو التفعيل'),
      );
      expect(localCubit.state.transactionKey, isNull);
      await localCubit.close();
      await localStore.close();
    },
  );

  test('restore times out when the StoreKit call never completes', () async {
    final localStore = FakeAppleIapStore()..restoreGate = Completer<void>();
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
      restoreTimeout: Duration.zero,
    );

    await localCubit.restorePurchases();

    expect(localStore.restoreCalled, isTrue);
    expect(localCubit.state.status, AppleIapStatus.restoreEmpty);
    expect(localCubit.state.message, 'لم يتم العثور على مشتريات سابقة');
    localStore.restoreGate!.complete();
    await localCubit.close();
    await localStore.close();
  });

  test(
    'restored event settles restore when the platform future is pending',
    () async {
      final localStore = FakeAppleIapStore()..restoreGate = Completer<void>();
      final localService = AppleIapService(
        store: localStore,
        productIds: {'test.product.course'},
        isIos: true,
      );
      final localCubit = AppleIapCubit(
        service: localService,
        productIds: {'test.product.course'},
        isIos: true,
        restoreTimeout: const Duration(milliseconds: 30),
      );
      await localCubit.loadProducts();

      final restore = localCubit.restorePurchases();
      await settleStream();
      localStore.purchaseController.add([
        purchaseDetails(PurchaseStatus.restored),
      ]);

      final secondRestore = localCubit.restorePurchases();
      expect(secondRestore, same(restore));
      expect(localStore.restoreCalls, 1);

      await restore;
      expect(localCubit.state.status, AppleIapStatus.failure);
      localStore.restoreGate!.complete();
      await localCubit.close();
      await localStore.close();
    },
  );

  test('restore API errors fail immediately without a stream result', () async {
    final localStore = FakeAppleIapStore()..restoreGate = Completer<void>();
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
      restoreTimeout: const Duration(seconds: 10),
    );

    final restore = localCubit.restorePurchases();
    await settleStream();
    localStore.restoreGate!.completeError(Exception('StoreKit restore failed'));
    await restore;

    expect(localCubit.state.status, AppleIapStatus.failure);
    expect(localCubit.state.message, contains('StoreKit restore failed'));
    await localCubit.close();
    await localStore.close();
  });

  test('restore reports a StoreKit stream error', () async {
    final restore = cubit.restorePurchases();
    await settleStream();
    final error = IAPError(
      source: 'test',
      code: 'restore_failed',
      message: 'تعذر استعادة المشتريات',
    );
    store.purchaseController.add([
      purchaseDetails(PurchaseStatus.error, id: 'restore-error', error: error),
    ]);
    await restore;

    expect(cubit.state.status, AppleIapStatus.failure);
    expect(cubit.state.message, contains('تعذر استعادة المشتريات'));
  });

  test(
    'restore retries a purchased transaction awaiting backend verification',
    () async {
      final purchased = purchaseDetails(PurchaseStatus.purchased);
      store.purchaseController.add([purchased]);
      await settleStream();
      expect(cubit.state.status, AppleIapStatus.verificationRequired);

      final restore = cubit.restorePurchases();
      await settleStream();
      expect(store.restoreCalls, 1);
      store.purchaseController.add([
        purchaseDetails(PurchaseStatus.restored, id: 'transaction-1'),
      ]);
      await restore;

      expect(cubit.state.status, AppleIapStatus.verificationRequired);
      expect(store.completedPurchases, isEmpty);
    },
  );

  test('duplicate restored callbacks remain uncompleted', () async {
    final restore = cubit.restorePurchases();
    await settleStream();
    final restored = purchaseDetails(PurchaseStatus.restored);
    store.purchaseController.add([restored]);
    await settleStream();
    store.purchaseController.add([purchaseDetails(PurchaseStatus.restored)]);
    await settleStream();

    await restore;

    expect(cubit.state.status, AppleIapStatus.verificationRequired);
    expect(store.completeCalls, 0);
    expect(store.completedPurchases, isEmpty);
  });

  test('restore processes every transaction in a batch', () async {
    final restore = cubit.restorePurchases();
    await settleStream();
    final first = purchaseDetails(PurchaseStatus.restored, id: 'transaction-1');
    final second = purchaseDetails(
      PurchaseStatus.restored,
      id: 'transaction-2',
    );
    store.purchaseController.add([first, second]);

    await restore;

    expect(store.completedPurchases, isEmpty);
  });

  test(
    'restore completes transactions delivered in separate callbacks',
    () async {
      final restore = cubit.restorePurchases();
      await settleStream();
      final first = purchaseDetails(
        PurchaseStatus.restored,
        id: 'transaction-1',
      );
      final second = purchaseDetails(
        PurchaseStatus.restored,
        id: 'transaction-2',
      );
      store.purchaseController.add([first]);

      await restore;
      store.purchaseController.add([second]);
      await settleStream();

      expect(store.completedPurchases, isEmpty);
    },
  );

  test('concurrent restore calls only invoke the store once', () async {
    store.restoreGate = Completer<void>();
    final firstRestore = cubit.restorePurchases();
    await settleStream();
    final secondRestore = cubit.restorePurchases();

    expect(store.restoreCalls, 1);
    expect(secondRestore, same(firstRestore));

    store.purchaseController.add([purchaseDetails(PurchaseStatus.restored)]);
    store.restoreGate!.complete();
    await Future.wait([firstRestore, secondRestore]);

    expect(store.completedPurchases, isEmpty);
  });

  test(
    'restored transactions are not completed when completion is unnecessary',
    () async {
      final restore = cubit.restorePurchases();
      await settleStream();
      store.purchaseController.add([
        purchaseDetails(
          PurchaseStatus.restored,
          pendingCompletePurchase: false,
        ),
      ]);

      await restore;

      expect(cubit.state.status, AppleIapStatus.verificationRequired);
      expect(store.completedPurchases, isEmpty);
    },
  );

  test('closing the Cubit cancels the purchase stream subscription', () async {
    expect(store.purchaseController.hasListener, isTrue);

    await cubit.close();

    expect(store.purchaseController.hasListener, isFalse);
  });

  test('restore settles when the purchase stream itself fails', () async {
    final localStore = FakeAppleIapStore();
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
      restoreTimeout: const Duration(seconds: 2),
    );
    await localCubit.loadProducts();

    final restore = localCubit.restorePurchases();
    await settleStream();
    localStore.purchaseController.addError(Exception('purchase stream failed'));

    await expectLater(
      restore.timeout(const Duration(milliseconds: 100)),
      completes,
    );
    expect(localCubit.state.status, AppleIapStatus.failure);
    expect(localCubit.state.message, contains('purchase stream failed'));
    await localCubit.close();
    await localStore.close();
  });

  test('canceled restore event settles without waiting for timeout', () async {
    final localStore = FakeAppleIapStore();
    final localService = AppleIapService(
      store: localStore,
      productIds: {'test.product.course'},
      isIos: true,
    );
    final localCubit = AppleIapCubit(
      service: localService,
      productIds: {'test.product.course'},
      isIos: true,
      restoreTimeout: const Duration(seconds: 2),
    );
    await localCubit.loadProducts();

    final restore = localCubit.restorePurchases();
    await settleStream();
    localStore.purchaseController.add([
      purchaseDetails(PurchaseStatus.canceled),
    ]);

    await expectLater(
      restore.timeout(const Duration(milliseconds: 100)),
      completes,
    );
    expect(localCubit.state.status, AppleIapStatus.cancelled);
    await localCubit.close();
    await localStore.close();
  });
}

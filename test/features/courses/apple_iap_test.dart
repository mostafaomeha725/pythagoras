import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_service.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_store.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_state.dart';
import 'package:pythagoras/core/services/remote_config_service.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/apple_iap_purchase_section.dart';

class FakeAppleIapStore implements AppleIapStore {
  final StreamController<List<PurchaseDetails>> purchaseController =
      StreamController<List<PurchaseDetails>>.broadcast();
  final List<PurchaseDetails> completedPurchases = [];
  bool available = true;
  @override
  bool isIapEnabled = true;
  bool purchaseStarted = true;
  int purchaseCalls = 0;
  bool restoreCalled = false;
  int restoreCalls = 0;
  Completer<void>? restoreGate;
  Completer<void>? completeGate;
  int completeCalls = 0;
  int loadProductsCalls = 0;
  ProductDetailsResponse response = ProductDetailsResponse(
    productDetails: const [],
    notFoundIDs: const [],
  );

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => purchaseController.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> loadProducts() async {
    loadProductsCalls++;
    return response;
  }

  @override
  Future<bool> purchase(ProductDetails product) async {
    purchaseCalls++;
    return purchaseStarted;
  }

  @override
  Future<void> restorePurchases() async {
    restoreCalled = true;
    restoreCalls++;
    final gate = restoreGate;
    if (gate != null) await gate.future;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completeCalls++;
    final gate = completeGate;
    if (gate != null) await gate.future;
    completedPurchases.add(purchase);
  }

  Future<void> close() => purchaseController.close();
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
    updates.add(value);
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
  bool pendingCompletePurchase = true,
  IAPError? error,
}) {
  final purchase = PurchaseDetails(
    purchaseID: id,
    productID: 'test.product.course',
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local-test-data',
      serverVerificationData: 'server-test-data',
      source: 'test',
    ),
    transactionDate: status == PurchaseStatus.pending ? null : '1',
    status: status,
  )..pendingCompletePurchase = pendingCompletePurchase;
  purchase.error = error;
  return purchase;
}

Future<void> settleStream() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  late FakeAppleIapStore store;
  late AppleIapService service;
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
    cubit = AppleIapCubit(
      service: service,
      productIds: {'test.product.course'},
      isIos: true,
    );
    await cubit.loadProducts();
  });

  tearDown(() async {
    await cubit.close();
    await store.close();
  });

  test('only Course 21 is eligible for automatic IAP product loading', () {
    expect(
      AppleIapProductCatalog.hasProductFor(AppleIapProductType.course, 21),
      isTrue,
    );
    expect(
      AppleIapProductCatalog.hasProductFor(AppleIapProductType.course, 22),
      isFalse,
    );
    expect(
      AppleIapProductCatalog.hasProductFor(AppleIapProductType.chapter, 1),
      isFalse,
    );
  });

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

  test('enrolled courses cannot load or invoke Apple IAP', () async {
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
    await localCubit.restorePurchases();

    expect(localCubit.state.products, isEmpty);
    expect(localStore.loadProductsCalls, 0);
    expect(localStore.purchaseCalls, 0);
    expect(localStore.restoreCalls, 0);
    await localCubit.close();
    await localStore.close();
  });

  test('pending enrollment requests also block Apple IAP', () async {
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
      hasPendingRequest: true,
    );

    await localCubit.loadProducts();
    await localCubit.restorePurchases();

    expect(localCubit.state.products, isEmpty);
    expect(localStore.loadProductsCalls, 0);
    expect(localStore.restoreCalls, 0);
    await localCubit.close();
    await localStore.close();
  });

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
    'API enrollment updates block and later restore IAP eligibility',
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

      await localCubit.updateCourseAccess(
        isEnrolled: true,
        hasPendingRequest: false,
      );
      expect(localCubit.state.products, isEmpty);
      await localCubit.purchase('test.product.course');
      await localCubit.restorePurchases();
      expect(localStore.purchaseCalls, 0);
      expect(localStore.restoreCalls, 0);

      await localCubit.updateCourseAccess(
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

  testWidgets('Apple actions are hidden for enrolled or pending courses', (
    tester,
  ) async {
    for (final access in [
      (isEnrolled: true, hasPendingRequest: false),
      (isEnrolled: false, hasPendingRequest: true),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleIapPurchaseSection(
              type: AppleIapProductType.course,
              contentId: 21,
              isEnrolled: access.isEnrolled,
              hasPendingRequest: access.hasPendingRequest,
            ),
          ),
        ),
      );
      expect(find.text('استعادة المشتريات'), findsNothing);
      expect(find.textContaining('شراء عبر Apple'), findsNothing);
    }
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

      store.purchaseController.add([purchaseDetails(PurchaseStatus.pending)]);
      await settleStream();
      expect(cubit.state.status, AppleIapStatus.pending);
      expect(store.completedPurchases, isEmpty);

      final purchased = purchaseDetails(PurchaseStatus.purchased);
      store.purchaseController.add([purchased]);
      await settleStream();
      expect(cubit.state.status, AppleIapStatus.purchaseConfirmed);
      expect(cubit.state.transactionKey, 'transaction-1');
      expect(store.completedPurchases, isEmpty);

      store.purchaseController.add([purchased]);
      await settleStream();
      expect(store.completedPurchases, isEmpty);
    },
  );

  test('cancellation and errors update state without completion', () async {
    store.purchaseController.add([purchaseDetails(PurchaseStatus.canceled)]);
    await settleStream();
    expect(cubit.state.status, AppleIapStatus.cancelled);
    expect(store.completedPurchases, isEmpty);

    final error = IAPError(
      source: 'test',
      code: 'failed',
      message: 'purchase failed',
    );
    store.purchaseController.add([
      purchaseDetails(PurchaseStatus.error, id: 'transaction-2', error: error),
    ]);
    await settleStream();
    expect(cubit.state.status, AppleIapStatus.failure);
    expect(cubit.state.message, 'purchase failed');
    expect(store.completedPurchases, isEmpty);
  });

  test(
    'confirmed purchase is completed only after the request succeeds',
    () async {
      final purchased = purchaseDetails(PurchaseStatus.purchased);
      store.purchaseController.add([purchased]);
      await settleStream();

      expect(cubit.state.status, AppleIapStatus.purchaseConfirmed);
      expect(store.completedPurchases, isEmpty);

      await cubit.completeConfirmedPurchase('transaction-1');
      expect(store.completedPurchases, [purchased]);

      await cubit.completeConfirmedPurchase('transaction-1');
      expect(store.completedPurchases, [purchased]);
    },
  );

  test(
    'a purchase that cannot start fails without leaving an active product',
    () async {
      store.purchaseStarted = false;

      await cubit.purchase('test.product.course');

      expect(cubit.state.status, AppleIapStatus.failure);
      expect(cubit.state.activeProductId, isNull);
      expect(store.completedPurchases, isEmpty);
    },
  );

  test('unknown products are ignored and cannot grant access', () async {
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

    store.purchaseController.add([unknown]);
    await settleStream();

    expect(cubit.state.status, AppleIapStatus.ready);
    expect(store.completedPurchases, isEmpty);
  });

  test('restored purchases are completed without creating a request', () async {
    final restore = cubit.restorePurchases();
    await settleStream();
    expect(store.restoreCalled, isTrue);

    final restored = purchaseDetails(PurchaseStatus.restored);
    store.purchaseController.add([restored]);
    await restore;
    expect(cubit.state.status, AppleIapStatus.restored);
    expect(cubit.state.transactionKey, isNull);
    expect(store.completedPurchases, hasLength(1));
    expect(cubit.state.message, contains('دون إنشاء طلب'));
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

      expect(cubit.state.status, AppleIapStatus.restored);
      expect(store.completedPurchases, hasLength(1));
    },
  );

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
      expect(localCubit.state.status, AppleIapStatus.restored);
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
    expect(cubit.state.message, 'تعذر استعادة المشتريات');
  });

  test(
    'restore is blocked while a purchased transaction awaits the backend',
    () async {
      final purchased = purchaseDetails(PurchaseStatus.purchased);
      store.purchaseController.add([purchased]);
      await settleStream();
      expect(cubit.state.status, AppleIapStatus.purchaseConfirmed);

      await cubit.restorePurchases();

      expect(store.restoreCalls, 0);
      expect(cubit.state.status, AppleIapStatus.purchaseConfirmed);
      expect(store.completedPurchases, isEmpty);
    },
  );

  test(
    'duplicate restored callbacks complete a transaction only once',
    () async {
      store.completeGate = Completer<void>();
      final restore = cubit.restorePurchases();
      await settleStream();
      final restored = purchaseDetails(PurchaseStatus.restored);
      store.purchaseController.add([restored]);
      await settleStream();
      store.purchaseController.add([purchaseDetails(PurchaseStatus.restored)]);
      await settleStream();

      expect(store.completeCalls, 1);
      var restoreFinished = false;
      restore.then((_) => restoreFinished = true);
      await settleStream();
      expect(restoreFinished, isFalse);

      store.completeGate!.complete();

      await restore;

      expect(cubit.state.status, AppleIapStatus.restored);
      expect(store.completedPurchases, [restored]);
    },
  );

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

    expect(store.completedPurchases, [first, second]);
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

      expect(store.completedPurchases, [first, second]);
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

    expect(store.completedPurchases, hasLength(1));
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

      expect(cubit.state.status, AppleIapStatus.restored);
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

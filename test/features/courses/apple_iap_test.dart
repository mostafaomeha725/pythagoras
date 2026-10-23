import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_service.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_store.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_state.dart';

class FakeAppleIapStore implements AppleIapStore {
  final StreamController<List<PurchaseDetails>> purchaseController =
      StreamController<List<PurchaseDetails>>.broadcast();
  final List<PurchaseDetails> completedPurchases = [];
  bool available = true;
  bool purchaseStarted = true;
  bool restoreCalled = false;
  ProductDetailsResponse response = ProductDetailsResponse(
    productDetails: const [],
    notFoundIDs: const [],
  );

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => purchaseController.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> loadProducts() async => response;

  @override
  Future<bool> purchase(ProductDetails product) async => purchaseStarted;

  @override
  Future<void> restorePurchases() async {
    restoreCalled = true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completedPurchases.add(purchase);
  }

  Future<void> close() => purchaseController.close();
}

ProductDetails product() => ProductDetails(
  id: 'test.product.course',
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
    await cubit.restorePurchases();
    expect(store.restoreCalled, isTrue);

    final restored = purchaseDetails(PurchaseStatus.restored);
    store.purchaseController.add([restored]);
    await settleStream();
    expect(cubit.state.status, AppleIapStatus.restored);
    expect(store.completedPurchases, hasLength(1));
    expect(cubit.state.message, contains('دون إنشاء طلب'));
  });
}

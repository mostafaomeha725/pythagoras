import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'apple_iap_store.dart';

class AppleIapService implements AppleIapStore {
  late final AppleIapStore _store;
  final Set<String>? _productIdsOverride;
  final bool _isIos;
  final bool Function() _isIapEnabled;
  final bool Function() _isAuthenticated;

  Set<String> get productIds => _productIdsOverride ?? const {};

  AppleIapService({
    AppleIapStore? store,
    InAppPurchase? inAppPurchase,
    Set<String>? productIds,
    bool? isIos,
    bool Function()? isIapEnabled,
    bool Function()? isAuthenticated,
  }) : _productIdsOverride = productIds,
       _isIos = isIos ?? defaultTargetPlatform == TargetPlatform.iOS,
       _isIapEnabled = isIapEnabled ?? (() => store?.isIapEnabled ?? false),
       _isAuthenticated = isAuthenticated ?? (() => false) {
    _store =
        store ?? _InAppPurchaseStore(inAppPurchase ?? InAppPurchase.instance);
  }

  @override
  bool get isIapEnabled => _isIapEnabled();

  bool get isIapEnabledOnIos => _isIos && _isIapEnabled();

  bool get isAuthenticated => _isAuthenticated();

  bool isProductEnabled(String productId) =>
      _isIos &&
      productId.trim().isNotEmpty &&
      (_productIdsOverride == null ||
          _productIdsOverride.contains(productId)) &&
      _isIapEnabled();

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _store.purchaseStream;

  @override
  Future<bool> isAvailable() async {
    if (!isIapEnabledOnIos ||
        (_productIdsOverride != null && _productIdsOverride.isEmpty)) {
      return false;
    }
    return _store.isAvailable();
  }

  @override
  Future<ProductDetailsResponse> loadProducts(Set<String> requestedIds) {
    final allowedIds = _productIdsOverride == null
        ? requestedIds
        : requestedIds.intersection(_productIdsOverride);
    if (!isIapEnabledOnIos || allowedIds.isEmpty) {
      return Future.value(
        ProductDetailsResponse(
          productDetails: const [],
          notFoundIDs: requestedIds.toList(growable: false),
        ),
      );
    }
    return _store.loadProducts(allowedIds);
  }

  @override
  Future<bool> purchase(ProductDetails product) {
    if (!isAuthenticated || !isProductEnabled(product.id)) {
      return Future.value(false);
    }
    return _store.purchase(product);
  }

  @override
  Future<void> restorePurchases() async {
    if (isAuthenticated && isIapEnabledOnIos) {
      await _store.restorePurchases();
    }
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _store.completePurchase(purchase);
    }
  }
}

class _InAppPurchaseStore implements AppleIapStore {
  final InAppPurchase _inAppPurchase;

  _InAppPurchaseStore(this._inAppPurchase);

  @override
  bool get isIapEnabled => true;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _inAppPurchase.purchaseStream;

  @override
  Future<bool> isAvailable() => _inAppPurchase.isAvailable();

  @override
  Future<ProductDetailsResponse> loadProducts(Set<String> productIds) =>
      _inAppPurchase.queryProductDetails(productIds);

  @override
  Future<bool> purchase(ProductDetails product) => _inAppPurchase
      .buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));

  @override
  Future<void> restorePurchases() => _inAppPurchase.restorePurchases();

  @override
  Future<void> completePurchase(PurchaseDetails purchase) =>
      _inAppPurchase.completePurchase(purchase);
}

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'apple_iap_product_catalog.dart';
import 'apple_iap_store.dart';

class AppleIapService implements AppleIapStore {
  late final AppleIapStore _store;
  final Set<String> productIds;
  final bool _isIos;

  AppleIapService({
    AppleIapStore? store,
    InAppPurchase? inAppPurchase,
    Set<String>? productIds,
    bool? isIos,
  }) : productIds = productIds ?? AppleIapProductCatalog.productIds,
       _isIos = isIos ?? defaultTargetPlatform == TargetPlatform.iOS {
    _store =
        store ??
        _InAppPurchaseStore(
          inAppPurchase ?? InAppPurchase.instance,
          this.productIds,
        );
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _store.purchaseStream;

  @override
  Future<bool> isAvailable() async {
    if (!_isIos) return false;
    return _store.isAvailable();
  }

  @override
  Future<ProductDetailsResponse> loadProducts() {
    return _store.loadProducts();
  }

  @override
  Future<bool> purchase(ProductDetails product) {
    return _store.purchase(product);
  }

  @override
  Future<void> restorePurchases() => _store.restorePurchases();

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _store.completePurchase(purchase);
    }
  }
}

class _InAppPurchaseStore implements AppleIapStore {
  final InAppPurchase _inAppPurchase;
  final Set<String> _productIds;

  _InAppPurchaseStore(this._inAppPurchase, this._productIds);

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _inAppPurchase.purchaseStream;

  @override
  Future<bool> isAvailable() => _inAppPurchase.isAvailable();

  @override
  Future<ProductDetailsResponse> loadProducts() =>
      _inAppPurchase.queryProductDetails(_productIds);

  @override
  Future<bool> purchase(ProductDetails product) => _inAppPurchase
      .buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));

  @override
  Future<void> restorePurchases() => _inAppPurchase.restorePurchases();

  @override
  Future<void> completePurchase(PurchaseDetails purchase) =>
      _inAppPurchase.completePurchase(purchase);
}

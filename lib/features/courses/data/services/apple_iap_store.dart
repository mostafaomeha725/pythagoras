import 'package:in_app_purchase/in_app_purchase.dart';

abstract interface class AppleIapStore {
  bool get isIapEnabled;

  Stream<List<PurchaseDetails>> get purchaseStream;

  Future<bool> isAvailable();

  Future<ProductDetailsResponse> loadProducts();

  Future<bool> purchase(ProductDetails product);

  Future<void> restorePurchases();

  Future<void> completePurchase(PurchaseDetails purchase);
}

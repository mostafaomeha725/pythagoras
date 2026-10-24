import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_store.dart';

import 'apple_iap_state.dart';

class AppleIapCubit extends Cubit<AppleIapState> {
  static const _submittedPurchaseKeysKey = 'apple_iap_submitted_purchase_keys';
  final AppleIapStore service;
  final Set<String> productIds;
  final bool _isIos;
  final SharedPreferences? _preferences;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  final Set<String> _processedTerminalPurchaseKeys = <String>{};
  final Map<String, PurchaseDetails> _pendingPurchases = {};
  late final Set<String> _submittedPurchaseKeys = {
    ...?_preferences?.getStringList(_submittedPurchaseKeysKey),
  };
  Future<void>? _loadFuture;

  AppleIapCubit({
    required this.service,
    Set<String>? productIds,
    bool? isIos,
    SharedPreferences? preferences,
  }) : _preferences = preferences,
       productIds = productIds ?? AppleIapProductCatalog.productIds,
       _isIos = isIos ?? defaultTargetPlatform == TargetPlatform.iOS,
       super(const AppleIapState());

  Future<void> loadProducts() => _loadFuture ??= _loadProducts();

  Future<void> _loadProducts() async {
    if (isClosed || !_isIos) return;
    if (productIds.isEmpty) {
      emit(state.copyWith(status: AppleIapStatus.unavailable));
      return;
    }

    emit(state.copyWith(status: AppleIapStatus.loading, clearMessage: true));
    try {
      final available = await service.isAvailable();
      debugPrint('[IAP][Store] isAvailable=$available productIds=$productIds');
      if (!available) {
        emit(state.copyWith(status: AppleIapStatus.unavailable));
        return;
      }

      await _purchaseSubscription?.cancel();
      _purchaseSubscription = service.purchaseStream.listen(_handlePurchases);
      final response = await service.loadProducts();
      debugPrint(
        '[IAP][Store] productDetails=${response.productDetails.map((product) => '${product.id}:${product.price}').toList()} '
        'notFoundIDs=${response.notFoundIDs} error=${response.error}',
      );
      if (isClosed) return;

      if (response.error != null) {
        emit(
          state.copyWith(
            status: AppleIapStatus.failure,
            message: response.error!.message,
          ),
        );
        return;
      }

      final products = response.productDetails
          .where((product) => productIds.contains(product.id))
          .toList(growable: false);
      emit(
        state.copyWith(
          status: products.isEmpty
              ? AppleIapStatus.unavailable
              : AppleIapStatus.ready,
          products: products,
        ),
      );
    } catch (error) {
      debugPrint('[IAP][Store] loadProducts error=$error');
      if (!isClosed) {
        emit(
          state.copyWith(
            status: AppleIapStatus.failure,
            message: error.toString(),
          ),
        );
      }
    }
  }

  Future<void> purchase(String productId) async {
    if (isClosed || state.status == AppleIapStatus.purchasing) return;
    ProductDetails? product;
    for (final item in state.products) {
      if (item.id == productId) {
        product = item;
        break;
      }
    }
    if (product == null) return;

    emit(
      state.copyWith(
        status: AppleIapStatus.purchasing,
        activeProductId: productId,
        clearMessage: true,
      ),
    );
    try {
      final started = await service.purchase(product);
      if (!started && !isClosed) {
        emit(
          state.copyWith(
            status: AppleIapStatus.failure,
            message: 'تعذر بدء عملية الشراء',
            clearActiveProductId: true,
          ),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: AppleIapStatus.failure,
            message: error.toString(),
            clearActiveProductId: true,
          ),
        );
      }
    }
  }

  Future<void> restorePurchases() async {
    if (isClosed || !_isIos) return;
    try {
      emit(state.copyWith(status: AppleIapStatus.loading, clearMessage: true));
      await service.restorePurchases();
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: AppleIapStatus.failure,
            message: error.toString(),
          ),
        );
      }
    }
  }

  Future<void> completeConfirmedPurchase(String transactionKey) async {
    final purchase = _pendingPurchases.remove(transactionKey);
    if (purchase == null) return;

    _submittedPurchaseKeys.add(transactionKey);
    await _preferences?.setStringList(
      _submittedPurchaseKeysKey,
      _submittedPurchaseKeys.toList(),
    );
    await service.completePurchase(purchase);
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (isClosed) return;
      if (!productIds.contains(purchase.productID)) continue;

      final purchaseKey = _purchaseKey(purchase);

      switch (purchase.status) {
        case PurchaseStatus.pending:
          emit(state.copyWith(status: AppleIapStatus.pending));
        case PurchaseStatus.canceled:
          if (!_processedTerminalPurchaseKeys.add(purchaseKey)) continue;
          emit(
            state.copyWith(
              status: AppleIapStatus.cancelled,
              message: 'تم إلغاء عملية الشراء',
              clearActiveProductId: true,
            ),
          );
        case PurchaseStatus.error:
          if (!_processedTerminalPurchaseKeys.add(purchaseKey)) continue;
          emit(
            state.copyWith(
              status: AppleIapStatus.failure,
              message: purchase.error?.message ?? 'فشلت عملية الشراء',
              clearActiveProductId: true,
            ),
          );
        case PurchaseStatus.purchased:
          if (!_processedTerminalPurchaseKeys.add(purchaseKey)) continue;
          if (_submittedPurchaseKeys.contains(purchaseKey)) {
            await service.completePurchase(purchase);
            emit(
              state.copyWith(
                status: AppleIapStatus.restored,
                clearActiveProductId: true,
                clearTransactionKey: true,
                message: 'تم إرسال طلب التفعيل مسبقًا',
              ),
            );
            continue;
          }
          _pendingPurchases[purchaseKey] = purchase;
          emit(
            state.copyWith(
              status: AppleIapStatus.purchaseConfirmed,
              activeProductId: purchase.productID,
              transactionKey: purchaseKey,
              message: 'تم تأكيد الشراء، وسيتم إرسال طلب التفعيل للمراجعة',
            ),
          );
        case PurchaseStatus.restored:
          if (!_processedTerminalPurchaseKeys.add(purchaseKey)) continue;
          await service.completePurchase(purchase);
          emit(
            state.copyWith(
              status: AppleIapStatus.restored,
              clearActiveProductId: true,
              clearTransactionKey: true,
              message: 'تمت استعادة المشتريات دون إنشاء طلب تفعيل جديد',
            ),
          );
      }
    }
  }

  String _purchaseKey(PurchaseDetails purchase) {
    final purchaseId = purchase.purchaseID?.trim();
    if (purchaseId != null && purchaseId.isNotEmpty) {
      return purchaseId;
    }

    return [
      purchase.productID,
      purchase.transactionDate ?? '',
      purchase.verificationData.serverVerificationData,
    ].join(':');
  }

  @override
  Future<void> close() async {
    await _purchaseSubscription?.cancel();
    return super.close();
  }
}

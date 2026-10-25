import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pythagoras/core/enums/app_enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_store.dart';

import 'apple_iap_state.dart';

class AppleIapCubit extends Cubit<AppleIapState> {
  static const _submittedPurchaseKeysKey = 'apple_iap_submitted_purchase_keys';
  static const _submittedPurchaseOwnersKey =
      'apple_iap_submitted_purchase_owners';
  final AppleIapStore service;
  final Set<String> productIds;
  final bool _isIos;
  final SharedPreferences? _preferences;
  final Duration _restoreTimeout;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  final Set<String> _processedTerminalPurchaseKeys = <String>{};
  final Set<String> _completedRestoredPurchaseKeys = <String>{};
  final Map<String, PurchaseDetails> _pendingPurchases = {};
  Completer<bool>? _restoreCompleter;
  Future<void>? _restoreFuture;
  bool _isCourseBlocked;
  late final Set<String> _submittedPurchaseKeys = {
    ...?_preferences?.getStringList(_submittedPurchaseKeysKey),
  };
  late final Map<String, int> _submittedPurchaseOwners =
      _readSubmittedPurchaseOwners();
  Future<void>? _loadFuture;

  AppleIapCubit({
    required this.service,
    Set<String>? productIds,
    bool? isIos,
    SharedPreferences? preferences,
    Duration restoreTimeout = const Duration(seconds: 10),
    bool isEnrolled = false,
    bool hasPendingRequest = false,
    bool isRequestStatusEligible = true,
  }) : _preferences = preferences,
       _restoreTimeout = restoreTimeout,
       _isCourseBlocked =
           !isRequestStatusEligible || isEnrolled || hasPendingRequest,
       productIds = productIds ?? AppleIapProductCatalog.productIds,
       _isIos = isIos ?? defaultTargetPlatform == TargetPlatform.iOS,
       super(const AppleIapState());

  Future<void> loadProducts() => _loadFuture ??= _loadProducts();

  Future<void> _loadProducts() async {
    if (isClosed || !_isIos) return;
    if (!service.isIapEnabled || _isCourseBlocked) {
      emit(
        state.copyWith(
          status: AppleIapStatus.unavailable,
          products: const [],
          clearActiveProductId: true,
          clearMessage: true,
        ),
      );
      return;
    }
    if (productIds.isEmpty) {
      emit(
        state.copyWith(
          status: AppleIapStatus.unavailable,
          products: const [],
          clearActiveProductId: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: AppleIapStatus.loading, clearMessage: true));
    try {
      final available = await service.isAvailable();
      debugPrint('[IAP][Store] isAvailable=$available productIds=$productIds');
      if (!available) {
        emit(
          state.copyWith(
            status: AppleIapStatus.unavailable,
            products: const [],
            clearActiveProductId: true,
          ),
        );
        return;
      }

      _listenToPurchaseStream();
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
            products: const [],
            clearActiveProductId: true,
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
            products: const [],
            clearActiveProductId: true,
            message: error.toString(),
          ),
        );
      }
    }
  }

  Future<void> purchase(String productId) async {
    if (isClosed ||
        !_isIos ||
        !service.isIapEnabled ||
        _isCourseBlocked ||
        _restoreFuture != null ||
        _isPurchaseInProgress ||
        state.status != AppleIapStatus.ready) {
      return;
    }
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

  Future<void> restorePurchases() {
    if (isClosed || !_isIos || !service.isIapEnabled || _isPurchaseInProgress) {
      return Future<void>.value();
    }
    return _restoreFuture ??= _restorePurchases();
  }

  bool get _isPurchaseInProgress =>
      state.status == AppleIapStatus.purchasing ||
      state.status == AppleIapStatus.pending ||
      state.status == AppleIapStatus.purchaseConfirmed;

  Future<void> updateIapEnabled(bool enabled) async {
    if (isClosed) return;
    _loadFuture = null;
    if (!enabled || _isCourseBlocked) {
      emit(
        state.copyWith(
          status: AppleIapStatus.unavailable,
          products: const [],
          clearActiveProductId: true,
          clearMessage: true,
        ),
      );
      return;
    }
    await loadProducts();
  }

  Future<void> updateCourseAccess({
    required bool isRequestStatusEligible,
    required bool isEnrolled,
    required bool hasPendingRequest,
  }) async {
    if (isClosed) return;
    final isBlocked =
        !isRequestStatusEligible || isEnrolled || hasPendingRequest;
    if (_isCourseBlocked == isBlocked) return;
    _isCourseBlocked = isBlocked;
    await updateIapEnabled(service.isIapEnabled);
  }

  Future<void> _restorePurchases() async {
    _listenToPurchaseStream();
    final restoreCompleter = Completer<bool>();
    _restoreCompleter = restoreCompleter;
    try {
      emit(
        state.copyWith(
          status: AppleIapStatus.loading,
          message: 'جاري استعادة المشتريات...',
        ),
      );
      final restoreResults =
          await Future.wait<dynamic>([
            service.restorePurchases(),
            restoreCompleter.future,
          ], eagerError: true).timeout(
            _restoreTimeout,
            onTimeout: () async => [
              null,
              restoreCompleter.isCompleted
                  ? await restoreCompleter.future
                  : false,
            ],
          );
      final restored = restoreResults[1] == true;
      if (!restored && !isClosed && state.status == AppleIapStatus.pending) {
        emit(
          state.copyWith(
            status: AppleIapStatus.failure,
            message:
                'معاملة Apple ما زالت قيد الانتظار؛ لم يتم تأكيد الدفع أو التفعيل.',
            clearActiveProductId: true,
          ),
        );
      } else if (!restored &&
          !isClosed &&
          state.status == AppleIapStatus.loading) {
        emit(
          state.copyWith(
            status: AppleIapStatus.restoreEmpty,
            message: 'لم يتم العثور على مشتريات سابقة',
          ),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: AppleIapStatus.failure,
            message: error.toString(),
          ),
        );
      }
    } finally {
      if (!restoreCompleter.isCompleted) {
        restoreCompleter.complete(false);
      }
      _restoreCompleter = null;
      _restoreFuture = null;
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
    final currentUserId = _preferences?.getInt(PreferencesKeys.userId.name);
    if (currentUserId != null) {
      _submittedPurchaseOwners[transactionKey] = currentUserId;
      await _preferences?.setStringList(
        _submittedPurchaseOwnersKey,
        _submittedPurchaseOwners.entries
            .map((entry) => '${entry.value}|${entry.key}')
            .toList(),
      );
    }
    await service.completePurchase(purchase);
  }

  Map<String, int> _readSubmittedPurchaseOwners() {
    final owners = <String, int>{};
    for (final record
        in _preferences?.getStringList(_submittedPurchaseOwnersKey) ??
            const <String>[]) {
      final separator = record.indexOf('|');
      if (separator <= 0) continue;
      final ownerId = int.tryParse(record.substring(0, separator));
      if (ownerId == null) continue;
      owners[record.substring(separator + 1)] = ownerId;
    }
    return owners;
  }

  void _finishRestore(bool restored) {
    final completer = _restoreCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(restored);
    }
  }

  void _listenToPurchaseStream() {
    _purchaseSubscription ??= service.purchaseStream.listen(
      _handlePurchases,
      onError: _handlePurchaseStreamError,
    );
  }

  void _handlePurchaseStreamError(Object error, StackTrace stackTrace) {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: AppleIapStatus.failure,
        message: error.toString(),
        clearActiveProductId: true,
      ),
    );
    _finishRestore(false);
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    var restoreSucceeded = false;
    var restoreFailed = false;
    for (final purchase in purchases) {
      if (isClosed) return;
      if (!productIds.contains(purchase.productID)) continue;

      final purchaseKey = _purchaseKey(purchase);
      final terminalPurchaseKey = '${purchase.status}:$purchaseKey';

      switch (purchase.status) {
        case PurchaseStatus.pending:
          emit(state.copyWith(status: AppleIapStatus.pending));
        case PurchaseStatus.canceled:
          restoreFailed = true;
          if (!_processedTerminalPurchaseKeys.add(terminalPurchaseKey)) {
            continue;
          }
          emit(
            state.copyWith(
              status: AppleIapStatus.cancelled,
              message: 'تم إلغاء عملية الشراء',
              clearActiveProductId: true,
            ),
          );
          await _completeRejectedPurchase(purchase, terminalPurchaseKey);
        case PurchaseStatus.error:
          restoreFailed = true;
          if (!_processedTerminalPurchaseKeys.add(terminalPurchaseKey)) {
            continue;
          }
          emit(
            state.copyWith(
              status: AppleIapStatus.failure,
              message: purchase.error?.message ?? 'فشلت عملية الشراء',
              clearActiveProductId: true,
            ),
          );
          await _completeRejectedPurchase(purchase, terminalPurchaseKey);
        case PurchaseStatus.purchased:
          if (!_processedTerminalPurchaseKeys.add(terminalPurchaseKey)) {
            continue;
          }
          if (_submittedPurchaseKeys.contains(purchaseKey)) {
            await service.completePurchase(purchase);
            final currentUserId = _preferences?.getInt(
              PreferencesKeys.userId.name,
            );
            final previousOwnerId = _submittedPurchaseOwners[purchaseKey];
            final message =
                previousOwnerId != null &&
                    currentUserId != null &&
                    previousOwnerId != currentUserId
                ? 'هذه المعاملة مسجلة محليًا لحساب طالب آخر. لم يتم نقلها أو إنشاء طلب جديد؛ سجّل الدخول بالحساب الأصلي أو تواصل مع الدعم.'
                : 'وُجد سجل محلي لهذه المعاملة، لكن لا يمكن تأكيد حالة طلب التفعيل أو ارتباطه بالحساب الحالي من الخادم. لم يتم إنشاء طلب جديد.';
            emit(
              state.copyWith(
                status: AppleIapStatus.failure,
                clearActiveProductId: true,
                clearTransactionKey: true,
                message: message,
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
          if (!_processedTerminalPurchaseKeys.add(terminalPurchaseKey)) {
            restoreSucceeded =
                restoreSucceeded ||
                _completedRestoredPurchaseKeys.contains(purchaseKey);
            continue;
          }
          try {
            await service.completePurchase(purchase);
            _completedRestoredPurchaseKeys.add(purchaseKey);
            restoreSucceeded = true;
            emit(
              state.copyWith(
                status: AppleIapStatus.restored,
                clearActiveProductId: true,
                clearTransactionKey: true,
                message: 'تمت استعادة المشتريات دون إنشاء طلب تفعيل جديد',
              ),
            );
          } catch (error) {
            _processedTerminalPurchaseKeys.remove(terminalPurchaseKey);
            restoreFailed = true;
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
    if (restoreFailed) {
      _finishRestore(false);
    } else if (restoreSucceeded) {
      _finishRestore(true);
    }
  }

  Future<void> _completeRejectedPurchase(
    PurchaseDetails purchase,
    String terminalPurchaseKey,
  ) async {
    try {
      await service.completePurchase(purchase);
    } catch (error) {
      _processedTerminalPurchaseKeys.remove(terminalPurchaseKey);
      emit(
        state.copyWith(
          status: AppleIapStatus.failure,
          message: error.toString(),
          clearActiveProductId: true,
        ),
      );
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
    _finishRestore(false);
    return super.close();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pythagoras/core/enums/app_enums.dart';
import 'package:pythagoras/features/courses/domain/entities/apple_purchase_verification_diagnostic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_service.dart';
import 'package:pythagoras/features/courses/domain/use_cases/verify_apple_purchase_use_case.dart';

import 'apple_iap_state.dart';

class AppleIapCubit extends Cubit<AppleIapState> {
  static const _submittedPurchaseKeysKey = 'apple_iap_submitted_purchase_keys';
  static const _submittedPurchaseOwnersKey =
      'apple_iap_submitted_purchase_owners';
  final AppleIapService service;
  final VerifyApplePurchaseUseCase? verifyApplePurchaseUseCase;
  final Map<String, AppleIapProductTarget> _productTargets;
  final bool _isIos;
  final SharedPreferences? _preferences;
  final Duration _restoreTimeout;
  final Duration _purchaseResponseTimeout;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Timer? _purchaseResponseTimer;
  final Set<String> _processedTerminalPurchaseKeys = <String>{};
  final Map<String, PurchaseDetails> _pendingPurchases = {};
  final Set<int> _eligibleChapterIds = <int>{};
  final Set<String> _conflictingProductIds = <String>{};
  String? _unresolvedProductId;
  String? _transactionConflictProductId;
  Completer<bool>? _restoreCompleter;
  Future<void>? _restoreFuture;
  bool _isCourseBlocked;
  int? _chapterParentCourseId;
  late final Set<String> _submittedPurchaseKeys = {
    ...?_preferences?.getStringList(_submittedPurchaseKeysKey),
  };
  late final Map<String, int> _submittedPurchaseOwners =
      _readSubmittedPurchaseOwners();
  Future<void>? _loadFuture;

  AppleIapCubit({
    required this.service,
    this.verifyApplePurchaseUseCase,
    Set<String>? productIds,
    Map<String, AppleIapProductTarget>? productTargets,
    bool? isIos,
    SharedPreferences? preferences,
    Duration restoreTimeout = const Duration(seconds: 10),
    Duration purchaseResponseTimeout = const Duration(seconds: 90),
    bool isEnrolled = false,
    bool hasPendingRequest = false,
    bool isRequestStatusEligible = true,
  }) : _preferences = preferences,
       _productTargets = Map.of(
         productTargets ??
             {
               for (final productId in productIds ?? const <String>{})
                 productId: const AppleIapProductTarget(
                   type: AppleIapProductType.course,
                   contentId: 0,
                 ),
             },
       ),
       _restoreTimeout = restoreTimeout,
       _purchaseResponseTimeout = purchaseResponseTimeout,
       _isCourseBlocked =
           !isRequestStatusEligible || isEnrolled || hasPendingRequest,
       _isIos = isIos ?? defaultTargetPlatform == TargetPlatform.iOS,
       super(const AppleIapState());

  Set<String> get productIds => _productTargets.keys.toSet();

  AppleIapProductTarget? targetFor(String productId) =>
      _productTargets[productId];

  bool isProductConfigurationConflict(String? productId) =>
      productId != null && _conflictingProductIds.contains(productId.trim());

  Future<void> loadProducts() => _loadFuture ??= _loadProducts();

  Future<void> _loadProducts() async {
    if (isClosed || !_isIos) return;
    final requestedProductIds = _eligibleProductIds;
    if (requestedProductIds.isEmpty) {
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
      final response = await service.loadProducts(requestedProductIds);
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
          .where((product) => requestedProductIds.contains(product.id))
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
        !service.isAuthenticated ||
        !_isProductEnabled(productId) ||
        _restoreFuture != null ||
        _isPurchaseInProgress ||
        _unresolvedProductId == productId ||
        state.status == AppleIapStatus.loading ||
        _transactionConflictProductId == productId) {
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

    debugPrint('[IAP][Purchase] requested productId=$productId');
    final target = targetFor(productId);
    if (target == null) return;
    emit(
      state.copyWith(
        status: AppleIapStatus.purchasing,
        activeProductId: productId,
        clearMessage: true,
      ),
    );
    try {
      final started = await service
          .purchase(product)
          .timeout(_purchaseResponseTimeout);
      if (!started && !isClosed) {
        _purchaseResponseTimer?.cancel();
        emit(
          state.copyWith(
            status: AppleIapStatus.failure,
            message:
                'تعذر بدء عملية الشراء. إذا كان Apple ID يملك المنتج بالفعل، استخدم استعادة المشتريات بدل تكرار الشراء.',
            clearActiveProductId: true,
          ),
        );
      } else if (started &&
          !isClosed &&
          state.status == AppleIapStatus.purchasing) {
        _purchaseResponseTimer?.cancel();
        _purchaseResponseTimer = Timer(
          _purchaseResponseTimeout,
          _emitPurchaseTimedOut,
        );
      }
    } catch (error) {
      if (!isClosed) {
        _purchaseResponseTimer?.cancel();
        if (error is TimeoutException) {
          _emitPurchaseTimedOut();
          return;
        }
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
    if (isClosed ||
        !_isIos ||
        !service.isAuthenticated ||
        !service.isIapEnabledOnIos ||
        _isPurchaseInProgress) {
      return Future<void>.value();
    }
    return _restoreFuture ??= _restorePurchases();
  }

  bool get _isPurchaseInProgress =>
      state.status == AppleIapStatus.purchasing ||
      state.status == AppleIapStatus.pending ||
      state.status == AppleIapStatus.verifying ||
      state.status == AppleIapStatus.purchaseConfirmed;

  bool get purchaseNeedsReconciliation => _unresolvedProductId != null;

  bool purchaseNeedsReconciliationFor(String productId) =>
      _unresolvedProductId == productId;

  void _emitPurchaseTimedOut() {
    if (isClosed ||
        (state.status != AppleIapStatus.purchasing &&
            state.status != AppleIapStatus.pending)) {
      return;
    }
    _unresolvedProductId = state.activeProductId;
    emit(
      state.copyWith(
        status: AppleIapStatus.purchaseTimedOut,
        message: state.status == AppleIapStatus.pending
            ? 'معاملة Apple ما زالت معلّقة. لم نبدأ محاولة أخرى؛ استخدم استعادة المشتريات للتحقق.'
            : 'لم يصل تأكيد من Apple. لم نبدأ محاولة أخرى؛ استخدم استعادة المشتريات للتحقق.',
      ),
    );
  }

  Future<void> updateIapEnabled(bool enabled) async {
    if (isClosed) return;
    _loadFuture = null;
    if (!enabled) {
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
    await updateIapEnabled(service.isIapEnabledOnIos);
  }

  Future<void> updateCourseAndChapterAccess({
    required int courseId,
    required bool isRequestStatusEligible,
    required bool isEnrolled,
    required bool hasPendingRequest,
    required Set<int> eligibleChapterIds,
    required String? courseAppleProductId,
    required Map<int, String?> chapterAppleProductIds,
  }) async {
    if (isClosed) return;
    _isCourseBlocked =
        !isRequestStatusEligible || isEnrolled || hasPendingRequest;
    _chapterParentCourseId = courseId;
    _eligibleChapterIds
      ..clear()
      ..addAll(eligibleChapterIds);

    final candidates = <String, AppleIapProductTarget>{};
    final conflictingIds = <String>{};
    void addTarget(String? rawProductId, AppleIapProductTarget target) {
      final productId = rawProductId?.trim();
      if (productId == null || productId.isEmpty) return;
      final previous = candidates[productId];
      if (previous != null &&
          (previous.type != target.type ||
              previous.contentId != target.contentId ||
              previous.parentContentId != target.parentContentId)) {
        conflictingIds.add(productId);
        return;
      }
      candidates[productId] = target;
    }

    addTarget(
      courseAppleProductId,
      AppleIapProductTarget(
        type: AppleIapProductType.course,
        contentId: courseId,
      ),
    );
    for (final entry in chapterAppleProductIds.entries) {
      addTarget(
        entry.value,
        AppleIapProductTarget(
          type: AppleIapProductType.chapter,
          contentId: entry.key,
          parentContentId: courseId,
        ),
      );
    }

    for (final productId in conflictingIds) {
      candidates.remove(productId);
      debugPrint(
        '[IAP][Configuration error] Product ID "$productId" is assigned to multiple course/chapter targets.',
      );
    }
    _conflictingProductIds
      ..clear()
      ..addAll(conflictingIds);
    _productTargets
      ..clear()
      ..addAll(candidates);
    await updateIapEnabled(service.isIapEnabledOnIos);
  }

  Set<String> get _eligibleProductIds => _productTargets.entries
      .where(
        (entry) =>
            service.isProductEnabled(entry.key) &&
            _isProductAccessEligible(entry.value),
      )
      .map((entry) => entry.key)
      .toSet();

  bool _isProductEnabled(String productId) {
    final target = targetFor(productId);
    return target != null &&
        service.isProductEnabled(productId) &&
        _isProductAccessEligible(target);
  }

  bool _isProductAccessEligible(AppleIapProductTarget target) {
    if (target.type == AppleIapProductType.chapter) {
      return target.parentContentId == _chapterParentCourseId &&
          _eligibleChapterIds.contains(target.contentId);
    }
    return !_isCourseBlocked;
  }

  Future<void> _restorePurchases() async {
    _listenToPurchaseStream();
    for (final purchaseKey in _pendingPurchases.keys) {
      _processedTerminalPurchaseKeys.remove(
        '${PurchaseStatus.restored}:$purchaseKey',
      );
    }
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
    var restoreFailed = false;
    for (final purchase in purchases) {
      if (isClosed) return;
      if (!productIds.contains(purchase.productID)) continue;

      final purchaseKey = _purchaseKey(purchase);
      final terminalPurchaseKey = '${purchase.status}:$purchaseKey';
      if (_processedTerminalPurchaseKeys.contains(terminalPurchaseKey)) {
        if (purchase.status == PurchaseStatus.restored) {
          restoreFailed = true;
        }
        continue;
      }
      if (purchase.status != PurchaseStatus.pending) {
        _purchaseResponseTimer?.cancel();
        if (_unresolvedProductId == purchase.productID) {
          _unresolvedProductId = null;
        }
      }
      debugPrint(
        '[IAP][Transaction] status=${purchase.status} '
        'productId=${purchase.productID} '
        'previouslySubmitted=${_submittedPurchaseKeys.contains(purchaseKey)}',
      );

      switch (purchase.status) {
        case PurchaseStatus.pending:
          emit(state.copyWith(status: AppleIapStatus.pending));
          if (_restoreFuture == null) {
            _purchaseResponseTimer?.cancel();
            _purchaseResponseTimer = Timer(
              _purchaseResponseTimeout,
              _emitPurchaseTimedOut,
            );
          }
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
              message:
                  '${purchase.error?.message ?? 'فشلت عملية الشراء'}. إذا كان Apple ID يملك المنتج بالفعل، استخدم استعادة المشتريات بدل تكرار الشراء.',
              clearActiveProductId: true,
            ),
          );
          await _completeRejectedPurchase(purchase, terminalPurchaseKey);
        case PurchaseStatus.purchased:
          if (!_processedTerminalPurchaseKeys.add(terminalPurchaseKey)) {
            continue;
          }
          if (_submittedPurchaseKeys.contains(purchaseKey)) {
            final currentUserId = _preferences?.getInt(
              PreferencesKeys.userId.name,
            );
            emit(
              _transactionConflictState(
                _submittedTransactionMessage(purchaseKey, currentUserId),
                productId: purchase.productID,
              ),
            );
            _transactionConflictProductId = purchase.productID;
            continue;
          }
          _pendingPurchases[purchaseKey] = purchase;
          _unresolvedProductId = purchase.productID;
          await _verifyPurchase(purchase: purchase, purchaseKey: purchaseKey);
        case PurchaseStatus.restored:
          if (!_processedTerminalPurchaseKeys.add(terminalPurchaseKey)) {
            restoreFailed = true;
            continue;
          }
          final currentUserId = _preferences?.getInt(
            PreferencesKeys.userId.name,
          );
          final previousOwnerId = _submittedPurchaseOwners[purchaseKey];
          if (_submittedPurchaseKeys.contains(purchaseKey) &&
              previousOwnerId != null &&
              currentUserId != null &&
              previousOwnerId != currentUserId) {
            restoreFailed = true;
            emit(
              _transactionConflictState(
                _submittedTransactionMessage(purchaseKey, currentUserId),
                productId: purchase.productID,
              ),
            );
            _transactionConflictProductId = purchase.productID;
            continue;
          }
          _pendingPurchases[purchaseKey] = purchase;
          _unresolvedProductId = purchase.productID;
          restoreFailed = true;
          await _verifyPurchase(purchase: purchase, purchaseKey: purchaseKey);
      }
    }
    if (restoreFailed) {
      _finishRestore(false);
    }
  }

  Future<void> _verifyPurchase({
    required PurchaseDetails purchase,
    required String purchaseKey,
  }) async {
    final signedTransaction = purchase.verificationData.serverVerificationData;
    final verifyUseCase = verifyApplePurchaseUseCase;
    if (signedTransaction.isEmpty || verifyUseCase == null) {
      emit(
        state.copyWith(
          status: AppleIapStatus.verificationRequired,
          activeProductId: purchase.productID,
          transactionKey: purchaseKey,
          message:
              'تعذر التحقق من الشراء. لم يتم تسجيل المحتوى؛ أعد المحاولة عبر استعادة المشتريات.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AppleIapStatus.verifying,
        activeProductId: purchase.productID,
        transactionKey: purchaseKey,
        message: 'جارٍ التحقق من عملية الشراء...',
      ),
    );

    final result = await verifyUseCase(signedTransaction);
    if (isClosed) return;

    final diagnosticText = _verificationDiagnosticText(result);
    if (result.isHttpResponse) {
      emit(
        state.copyWith(
          status: AppleIapStatus.verificationRequired,
          activeProductId: purchase.productID,
          transactionKey: purchaseKey,
          message:
              'وصل رد التحقق، لكن لا يمكن تأكيد الاستحقاق لأن عقد استجابة الخادم غير موثق. لم يتم تسجيل المحتوى.',
          verificationDiagnostic: diagnosticText,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AppleIapStatus.failure,
        activeProductId: purchase.productID,
        transactionKey: purchaseKey,
        message:
            'تعذر الاتصال بخدمة التحقق. لم يتم تسجيل المحتوى؛ أعد المحاولة عبر استعادة المشتريات.',
        verificationDiagnostic: diagnosticText,
      ),
    );
  }

  String _verificationDiagnosticText(
    ApplePurchaseVerificationDiagnostic diagnostic,
  ) {
    if (diagnostic.isHttpResponse) {
      final body = (diagnostic.responseBody ?? '').trim();
      return 'HTTP ${diagnostic.statusCode}\n${body.isNotEmpty ? body : 'response body empty'}';
    }

    final error = (diagnostic.networkError ?? 'تعذر الاتصال بخدمة التحقق')
        .trim();
    return 'NETWORK_ERROR\n$error';
  }

  String _submittedTransactionMessage(String purchaseKey, int? currentUserId) {
    final previousOwnerId = _submittedPurchaseOwners[purchaseKey];
    if (previousOwnerId != null &&
        currentUserId != null &&
        previousOwnerId != currentUserId) {
      return 'هذه المعاملة مسجلة محليًا لحساب طالب آخر. لم يتم نقلها أو إنشاء طلب جديد؛ سجّل الدخول بالحساب الأصلي أو تواصل مع الدعم.';
    }
    return 'هذه المعاملة مسجلة مسبقًا. لم يتم إنشاء طلب جديد أو تفعيل هذا الحساب؛ استخدم الحساب المرتبط بها أو تواصل مع الدعم.';
  }

  AppleIapState _transactionConflictState(
    String message, {
    required String productId,
  }) {
    return state.copyWith(
      status: AppleIapStatus.transactionConflict,
      activeProductId: productId,
      clearTransactionKey: true,
      message: message,
    );
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

    final serverDataDigest = sha256
        .convert(utf8.encode(purchase.verificationData.serverVerificationData))
        .toString();
    return [
      purchase.productID,
      purchase.transactionDate ?? '',
      serverDataDigest,
    ].join(':');
  }

  @override
  Future<void> close() async {
    _purchaseResponseTimer?.cancel();
    await _purchaseSubscription?.cancel();
    _finishRestore(false);
    return super.close();
  }
}

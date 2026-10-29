import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/enums/app_enums.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_service.dart';
import 'package:pythagoras/features/courses/domain/use_cases/enroll_chapter_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/enroll_course_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/verify_apple_purchase_use_case.dart';
import 'package:pythagoras/features/courses/domain/entities/enrollment_result.dart';
import 'package:pythagoras/features/courses/domain/entities/apple_purchase_verification_result.dart';

import 'apple_iap_state.dart';

class AppleIapCubit extends Cubit<AppleIapState> {
  static const _submittedPurchaseKeysKey = 'apple_iap_submitted_purchase_keys';
  static const _submittedPurchaseOwnersKey =
      'apple_iap_submitted_purchase_owners';
  static const _pendingEnrollmentRecordsKey =
      'apple_iap_pending_enrollment_records';
  final AppleIapService service;
  final VerifyApplePurchaseUseCase? verifyApplePurchaseUseCase;
  final EnrollCourseUseCase? enrollCourseUseCase;
  final EnrollChapterUseCase? enrollChapterUseCase;
  final Map<String, AppleIapProductTarget> _productTargets;
  final bool _isIos;
  final SharedPreferences? _preferences;
  final Duration _restoreTimeout;
  final Duration _purchaseResponseTimeout;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Timer? _purchaseResponseTimer;
  final Set<String> _processedTerminalPurchaseKeys = <String>{};
  final Set<String> _successfulTerminalPurchaseKeys = <String>{};
  final Set<String> _enrollmentKeysInFlight = <String>{};
  final Map<String, PurchaseDetails> _pendingPurchases = {};
  late final Map<String, _PendingAppleEnrollment> _pendingEnrollmentRecords =
      _readPendingEnrollmentRecords();
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
    this.enrollCourseUseCase,
    this.enrollChapterUseCase,
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

  Map<String, _PendingAppleEnrollment> _readPendingEnrollmentRecords() {
    final records = <String, _PendingAppleEnrollment>{};
    for (final serialized
        in _preferences?.getStringList(_pendingEnrollmentRecordsKey) ??
            const <String>[]) {
      try {
        final decoded = jsonDecode(serialized);
        if (decoded is! Map<String, dynamic>) continue;
        final record = _PendingAppleEnrollment.fromJson(decoded);
        if (record != null) records[record.transactionKey] = record;
      } catch (_) {
        // Corrupt local metadata is ignored and never grants access.
      }
    }
    return records;
  }

  Future<bool> _persistPendingEnrollmentRecords() async {
    final preferences = _preferences;
    if (preferences == null) return false;
    try {
      return await preferences.setStringList(
        _pendingEnrollmentRecordsKey,
        _pendingEnrollmentRecords.values
            .map((record) => jsonEncode(record.toJson()))
            .toList(growable: false),
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> _persistSubmittedPurchaseOwnership() async {
    final preferences = _preferences;
    if (preferences == null) return false;
    try {
      final keysSaved = await preferences.setStringList(
        _submittedPurchaseKeysKey,
        _submittedPurchaseKeys.toList(growable: false),
      );
      final ownersSaved = await preferences.setStringList(
        _submittedPurchaseOwnersKey,
        _submittedPurchaseOwners.entries
            .map((entry) => '${entry.value}|${entry.key}')
            .toList(growable: false),
      );
      return keysSaved && ownersSaved;
    } catch (_) {
      return false;
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
    var sawRestoreResult = false;
    for (final purchase in purchases) {
      if (isClosed) return;

      final purchaseKey = _purchaseKey(purchase);
      final terminalPurchaseKey = '${purchase.status}:$purchaseKey';
      if (_processedTerminalPurchaseKeys.contains(terminalPurchaseKey)) {
        if (purchase.status == PurchaseStatus.restored &&
            !_successfulTerminalPurchaseKeys.contains(terminalPurchaseKey)) {
          restoreFailed = true;
          sawRestoreResult = true;
        }
        continue;
      }
      if (purchase.status != PurchaseStatus.pending && _restoreFuture != null) {
        sawRestoreResult = true;
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

      final savedEnrollment = _pendingEnrollmentRecords[purchaseKey];
      if ((purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) &&
          !productIds.contains(purchase.productID) &&
          (savedEnrollment == null ||
              savedEnrollment.productId != purchase.productID)) {
        _processedTerminalPurchaseKeys.add(terminalPurchaseKey);
        if (purchase.status == PurchaseStatus.restored) {
          restoreFailed = true;
        }
        _pendingPurchases[purchaseKey] = purchase;
        _unresolvedProductId = purchase.productID;
        emit(
          state.copyWith(
            status: AppleIapStatus.verificationRequired,
            activeProductId: purchase.productID,
            transactionKey: purchaseKey,
            message:
                'وصلت معاملة لمنتج غير موجود في المحتوى المفتوح. لم يتم التحقق أو التسجيل؛ افتح المحتوى المرتبط بالمنتج ثم أعد Restore.',
          ),
        );
        continue;
      }

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
          if (_restoreFuture != null) restoreFailed = true;
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
          if (_restoreFuture != null) restoreFailed = true;
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
            if (currentUserId == null ||
                _submittedPurchaseOwners[purchaseKey] != currentUserId) {
              emit(
                _transactionConflictState(
                  _submittedTransactionMessage(purchaseKey, currentUserId),
                  productId: purchase.productID,
                ),
              );
              _transactionConflictProductId = purchase.productID;
              continue;
            }
          }
          _pendingPurchases[purchaseKey] = purchase;
          _unresolvedProductId = purchase.productID;
          await _verifyPurchase(
            purchase: purchase,
            purchaseKey: purchaseKey,
            isRestored: false,
          );
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
          final verifiedAndEnrolled = await _verifyPurchase(
            purchase: purchase,
            purchaseKey: purchaseKey,
            isRestored: true,
          );
          if (!verifiedAndEnrolled) restoreFailed = true;
      }
    }
    if (sawRestoreResult) {
      _finishRestore(!restoreFailed);
    }
  }

  Future<bool> _verifyPurchase({
    required PurchaseDetails purchase,
    required String purchaseKey,
    required bool isRestored,
  }) async {
    final savedRecord = _pendingEnrollmentRecords[purchaseKey];
    final target = savedRecord?.target ?? targetFor(purchase.productID);
    final currentUserId = _preferences?.getInt(PreferencesKeys.userId.name);
    final currentTarget = targetFor(purchase.productID);

    if (savedRecord != null &&
        (savedRecord.productId != purchase.productID ||
            savedRecord.ownerId != currentUserId ||
            (currentTarget != null &&
                !_sameTarget(savedRecord.target, currentTarget)))) {
      emit(
        _transactionConflictState(
          'المعاملة المؤكدة مرتبطة بحساب أو محتوى آخر. لم يتم التسجيل.',
          productId: purchase.productID,
        ),
      );
      return false;
    }

    final signedTransaction = purchase.verificationData.serverVerificationData;
    final verifyUseCase = verifyApplePurchaseUseCase;
    if (signedTransaction.isEmpty || verifyUseCase == null || target == null) {
      emit(
        state.copyWith(
          status: AppleIapStatus.failure,
          activeProductId: purchase.productID,
          transactionKey: purchaseKey,
          message:
              'تعذر تحديد محتوى المعاملة أو التحقق منها. لم يتم التسجيل؛ افتح المحتوى الصحيح ثم أعد Restore.',
          clearVerificationStatusCode: true,
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        status: AppleIapStatus.verifying,
        activeProductId: purchase.productID,
        transactionKey: purchaseKey,
        message: 'جارٍ التحقق من عملية الشراء...',
        clearVerificationStatusCode: true,
      ),
    );

    ApplePurchaseVerificationResult result;
    try {
      result = await verifyUseCase(signedTransaction);
    } catch (_) {
      emit(
        state.copyWith(
          status: AppleIapStatus.failure,
          activeProductId: purchase.productID,
          transactionKey: purchaseKey,
          message:
              'تعذر الاتصال بخدمة التحقق. لم يتم التسجيل؛ أعد Restore لإعادة المحاولة.',
          clearVerificationStatusCode: true,
        ),
      );
      return false;
    }
    if (isClosed) return false;
    if (!result.isVerified) {
      emit(
        state.copyWith(
          status: AppleIapStatus.failure,
          activeProductId: purchase.productID,
          transactionKey: purchaseKey,
          message: result.isHttpResponse
              ? 'رفض خادم التحقق المعاملة (HTTP ${result.statusCode}). لم يتم التسجيل؛ أعد Restore لإعادة المحاولة.'
              : '${result.networkError ?? 'تعذر الاتصال بخدمة التحقق'}. لم يتم التسجيل؛ أعد Restore لإعادة المحاولة.',
          verificationStatusCode: result.statusCode,
        ),
      );
      return false;
    }

    if (enrollCourseUseCase == null || enrollChapterUseCase == null) {
      emit(
        state.copyWith(
          status: AppleIapStatus.verificationRequired,
          activeProductId: purchase.productID,
          transactionKey: purchaseKey,
          verificationStatusCode: 200,
          message:
              'تم التحقق من المعاملة (HTTP 200)، لكن مسار التسجيل غير مهيأ. لم يتم منح المحتوى.',
        ),
      );
      return false;
    }

    if (target.contentId <= 0 ||
        (target.type == AppleIapProductType.chapter &&
            (target.parentContentId == null || target.parentContentId! <= 0))) {
      emit(
        state.copyWith(
          status: AppleIapStatus.verificationRequired,
          activeProductId: purchase.productID,
          transactionKey: purchaseKey,
          verificationStatusCode: 200,
          message:
              'تم التحقق من المعاملة، لكن ربط المنتج بالمحتوى غير صالح. لم يتم التسجيل.',
        ),
      );
      return false;
    }

    if (currentUserId == null || !service.isAuthenticated) {
      emit(
        state.copyWith(
          status: AppleIapStatus.verificationRequired,
          activeProductId: purchase.productID,
          transactionKey: purchaseKey,
          verificationStatusCode: 200,
          message:
              'تم التحقق من المعاملة، لكن تعذر تحديد الحساب المرتبط بها. لم يتم التسجيل؛ أعد Restore بعد تسجيل الدخول.',
        ),
      );
      return false;
    }

    if (_submittedPurchaseKeys.contains(purchaseKey)) {
      if (_submittedPurchaseOwners[purchaseKey] != currentUserId) {
        emit(
          _transactionConflictState(
            _submittedTransactionMessage(purchaseKey, currentUserId),
            productId: purchase.productID,
          ),
        );
        return false;
      }
      return _completePreviouslyEnrolledPurchase(
        purchase: purchase,
        purchaseKey: purchaseKey,
        productId: purchase.productID,
        isRestored: isRestored,
      );
    }

    final record =
        savedRecord ??
        _PendingAppleEnrollment(
          transactionKey: purchaseKey,
          productId: purchase.productID,
          ownerId: currentUserId,
          target: target,
        );
    _pendingEnrollmentRecords[purchaseKey] = record;
    if (!await _persistPendingEnrollmentRecords()) {
      _pendingEnrollmentRecords.remove(purchaseKey);
      emit(
        state.copyWith(
          status: AppleIapStatus.failure,
          activeProductId: purchase.productID,
          transactionKey: purchaseKey,
          verificationStatusCode: 200,
          message:
              'تم التحقق من المعاملة، لكن تعذر حفظ حالة الاستحقاق. لم يتم التسجيل أو إكمال معاملة Apple؛ أعد Restore.',
        ),
      );
      return false;
    }

    return _enrollVerifiedPurchase(
      record: record,
      purchase: purchase,
      purchaseKey: purchaseKey,
      isRestored: isRestored,
    );
  }

  bool _sameTarget(AppleIapProductTarget left, AppleIapProductTarget right) =>
      left.type == right.type &&
      left.contentId == right.contentId &&
      left.parentContentId == right.parentContentId;

  Future<bool> _completePreviouslyEnrolledPurchase({
    required PurchaseDetails purchase,
    required String purchaseKey,
    required String productId,
    required bool isRestored,
  }) async {
    var completed = true;
    try {
      await service.completePurchase(purchase);
    } catch (_) {
      completed = false;
    }

    if (completed) {
      _successfulTerminalPurchaseKeys.add('${purchase.status}:$purchaseKey');
      _pendingPurchases.remove(purchaseKey);
      _pendingEnrollmentRecords.remove(purchaseKey);
      await _persistPendingEnrollmentRecords();
      if (_unresolvedProductId == productId) _unresolvedProductId = null;
    }

    emit(
      state.copyWith(
        status: isRestored
            ? AppleIapStatus.restored
            : AppleIapStatus.purchaseConfirmed,
        activeProductId: productId,
        transactionKey: purchaseKey,
        verificationStatusCode: 200,
        message: completed
            ? 'تم تأكيد الشراء، والمحتوى متاح بالفعل'
            : 'تم تأكيد الشراء والمحتوى متاح، لكن تعذر تأكيد معاملة Apple. أعد Restore للتسوية.',
        alreadyEnrolled: true,
      ),
    );
    return completed;
  }

  Future<bool> _enrollVerifiedPurchase({
    required _PendingAppleEnrollment record,
    required PurchaseDetails purchase,
    required String purchaseKey,
    required bool isRestored,
  }) async {
    if (isClosed || !_enrollmentKeysInFlight.add(purchaseKey)) return false;
    try {
      final currentUserId = _preferences?.getInt(PreferencesKeys.userId.name);
      final currentTarget = targetFor(record.productId);
      if (!service.isAuthenticated ||
          currentUserId != record.ownerId ||
          (currentTarget != null &&
              !_sameTarget(record.target, currentTarget))) {
        emit(
          _transactionConflictState(
            'المعاملة المؤكدة لا تطابق الحساب أو المحتوى الحالي. لم يتم التسجيل.',
            productId: record.productId,
          ),
        );
        return false;
      }

      final Either<Failure, EnrollmentResult> result;
      try {
        result = record.target.type == AppleIapProductType.course
            ? await enrollCourseUseCase!(record.target.contentId)
            : await enrollChapterUseCase!(record.target.contentId);
      } catch (_) {
        emit(
          state.copyWith(
            status: AppleIapStatus.failure,
            activeProductId: record.productId,
            transactionKey: purchaseKey,
            verificationStatusCode: 200,
            message:
                'تم التحقق من الشراء، لكن تعذر تسجيل المحتوى. لم يتم إكمال معاملة Apple؛ أعد Restore لإعادة التسجيل دون شراء جديد.',
          ),
        );
        return false;
      }
      final enrollmentResult = result.fold<EnrollmentResult?>(
        (_) => null,
        (enrollment) => enrollment,
      );
      if (enrollmentResult == null) {
        emit(
          state.copyWith(
            status: AppleIapStatus.failure,
            activeProductId: record.productId,
            transactionKey: purchaseKey,
            verificationStatusCode: 200,
            message:
                'تم التحقق من الشراء، لكن تعذر تسجيل المحتوى. لم يتم إكمال معاملة Apple؛ أعد Restore لإعادة التسجيل دون شراء جديد.',
          ),
        );
        return false;
      }

      _submittedPurchaseKeys.add(purchaseKey);
      _submittedPurchaseOwners[purchaseKey] = record.ownerId;
      if (!await _persistSubmittedPurchaseOwnership()) {
        _submittedPurchaseKeys.remove(purchaseKey);
        _submittedPurchaseOwners.remove(purchaseKey);
        emit(
          state.copyWith(
            status: AppleIapStatus.failure,
            activeProductId: record.productId,
            transactionKey: purchaseKey,
            verificationStatusCode: 200,
            message:
                'تم التسجيل، لكن تعذر حفظ حالة المعاملة. لم تكتمل معاملة Apple؛ أعد Restore للتسوية.',
          ),
        );
        return false;
      }

      var completed = true;
      try {
        await service.completePurchase(purchase);
      } catch (_) {
        completed = false;
      }

      if (completed) {
        _successfulTerminalPurchaseKeys.add('${purchase.status}:$purchaseKey');
        _pendingPurchases.remove(purchaseKey);
        _pendingEnrollmentRecords.remove(purchaseKey);
        if (!await _persistPendingEnrollmentRecords()) {
          _pendingEnrollmentRecords[purchaseKey] = record;
        }
        if (_unresolvedProductId == record.productId) {
          _unresolvedProductId = null;
        }
      }
      emit(
        state.copyWith(
          status: isRestored
              ? AppleIapStatus.restored
              : AppleIapStatus.purchaseConfirmed,
          activeProductId: record.productId,
          transactionKey: purchaseKey,
          verificationStatusCode: 200,
          message: completed
              ? enrollmentResult.message
              : 'تم تسجيل المحتوى، لكن تعذر تأكيد معاملة Apple. أعد Restore للتسوية دون شراء جديد.',
          alreadyEnrolled: enrollmentResult.alreadyEnrolled,
        ),
      );
      return completed;
    } finally {
      _enrollmentKeysInFlight.remove(purchaseKey);
    }
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

class _PendingAppleEnrollment {
  final String transactionKey;
  final String productId;
  final int ownerId;
  final AppleIapProductTarget target;

  const _PendingAppleEnrollment({
    required this.transactionKey,
    required this.productId,
    required this.ownerId,
    required this.target,
  });

  Map<String, Object?> toJson() => {
    'transactionKey': transactionKey,
    'productId': productId,
    'ownerId': ownerId,
    'targetType': target.type.name,
    'contentId': target.contentId,
    'parentContentId': target.parentContentId,
  };

  static _PendingAppleEnrollment? fromJson(Map<String, dynamic> json) {
    final transactionKey = json['transactionKey'];
    final productId = json['productId'];
    final ownerId = json['ownerId'];
    final typeName = json['targetType'];
    final contentId = json['contentId'];
    final parentContentId = json['parentContentId'];
    if (transactionKey is! String ||
        transactionKey.isEmpty ||
        productId is! String ||
        productId.isEmpty ||
        ownerId is! int ||
        typeName is! String ||
        contentId is! int) {
      return null;
    }
    final productType = AppleIapProductType.values.where(
      (candidate) => candidate.name == typeName,
    );
    if (productType.isEmpty ||
        (productType.single == AppleIapProductType.chapter &&
            parentContentId is! int)) {
      return null;
    }
    return _PendingAppleEnrollment(
      transactionKey: transactionKey,
      productId: productId,
      ownerId: ownerId,
      target: AppleIapProductTarget(
        type: productType.single,
        contentId: contentId,
        parentContentId: parentContentId is int ? parentContentId : null,
      ),
    );
  }
}

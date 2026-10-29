import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

enum AppleIapStatus {
  initial,
  loading,
  ready,
  purchasing,
  pending,
  verifying,
  cancelled,
  restored,
  restoreEmpty,
  purchaseConfirmed,
  verificationRequired,
  transactionConflict,
  purchaseTimedOut,
  unavailable,
  failure,
}

class AppleIapState extends Equatable {
  final AppleIapStatus status;
  final List<ProductDetails> products;
  final String? activeProductId;
  final String? transactionKey;
  final String? message;
  final int? verificationStatusCode;
  final bool alreadyEnrolled;
  final bool restoreInProgress;
  final bool restoreHasConfirmedEnrollment;
  final bool restoreHasUnmappedProducts;

  const AppleIapState({
    this.status = AppleIapStatus.initial,
    this.products = const [],
    this.activeProductId,
    this.transactionKey,
    this.message,
    this.verificationStatusCode,
    this.alreadyEnrolled = false,
    this.restoreInProgress = false,
    this.restoreHasConfirmedEnrollment = false,
    this.restoreHasUnmappedProducts = false,
  });

  AppleIapState copyWith({
    AppleIapStatus? status,
    List<ProductDetails>? products,
    String? activeProductId,
    bool clearActiveProductId = false,
    String? transactionKey,
    bool clearTransactionKey = false,
    String? message,
    bool clearMessage = false,
    int? verificationStatusCode,
    bool clearVerificationStatusCode = false,
    bool alreadyEnrolled = false,
    bool? restoreInProgress,
    bool? restoreHasConfirmedEnrollment,
    bool? restoreHasUnmappedProducts,
  }) {
    return AppleIapState(
      status: status ?? this.status,
      products: products ?? this.products,
      activeProductId: clearActiveProductId
          ? null
          : (activeProductId ?? this.activeProductId),
      transactionKey: clearTransactionKey
          ? null
          : (transactionKey ?? this.transactionKey),
      message: clearMessage ? null : (message ?? this.message),
      verificationStatusCode: clearVerificationStatusCode
          ? null
          : (verificationStatusCode ?? this.verificationStatusCode),
      alreadyEnrolled: alreadyEnrolled,
      restoreInProgress: restoreInProgress ?? this.restoreInProgress,
      restoreHasConfirmedEnrollment:
          restoreHasConfirmedEnrollment ?? this.restoreHasConfirmedEnrollment,
      restoreHasUnmappedProducts:
          restoreHasUnmappedProducts ?? this.restoreHasUnmappedProducts,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    activeProductId,
    transactionKey,
    message,
    verificationStatusCode,
    alreadyEnrolled,
    restoreInProgress,
    restoreHasConfirmedEnrollment,
    restoreHasUnmappedProducts,
  ];
}

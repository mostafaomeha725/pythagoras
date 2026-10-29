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

  const AppleIapState({
    this.status = AppleIapStatus.initial,
    this.products = const [],
    this.activeProductId,
    this.transactionKey,
    this.message,
    this.verificationStatusCode,
    this.alreadyEnrolled = false,
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
  ];
}

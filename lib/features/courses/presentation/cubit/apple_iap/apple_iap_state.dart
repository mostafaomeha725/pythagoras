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
  final String? verificationDiagnostic;
  final int? verificationStatusCode;
  final String? verificationResponseBody;
  final String? verificationNetworkError;

  const AppleIapState({
    this.status = AppleIapStatus.initial,
    this.products = const [],
    this.activeProductId,
    this.transactionKey,
    this.message,
    this.verificationDiagnostic,
    this.verificationStatusCode,
    this.verificationResponseBody,
    this.verificationNetworkError,
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
    String? verificationDiagnostic,
    bool clearVerificationDiagnostic = false,
    int? verificationStatusCode,
    String? verificationResponseBody,
    String? verificationNetworkError,
    bool clearVerificationPayload = false,
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
      verificationDiagnostic: clearVerificationDiagnostic
          ? null
          : (verificationDiagnostic ?? this.verificationDiagnostic),
      verificationStatusCode: clearVerificationPayload
          ? null
          : (verificationStatusCode ?? this.verificationStatusCode),
      verificationResponseBody: clearVerificationPayload
          ? null
          : (verificationResponseBody ?? this.verificationResponseBody),
      verificationNetworkError: clearVerificationPayload
          ? null
          : (verificationNetworkError ?? this.verificationNetworkError),
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    activeProductId,
    transactionKey,
    message,
    verificationDiagnostic,
    verificationStatusCode,
    verificationResponseBody,
    verificationNetworkError,
  ];
}

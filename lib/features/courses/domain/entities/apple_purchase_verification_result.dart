class ApplePurchaseVerificationResult {
  final int? statusCode;
  final String? networkError;

  const ApplePurchaseVerificationResult.http(this.statusCode)
    : networkError = null;

  const ApplePurchaseVerificationResult.networkError(this.networkError)
    : statusCode = null;

  bool get isHttpResponse => statusCode != null;
  bool get isVerified => statusCode == 200;
}

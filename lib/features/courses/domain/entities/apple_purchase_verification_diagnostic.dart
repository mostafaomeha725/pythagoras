class ApplePurchaseVerificationDiagnostic {
  final int? statusCode;
  final String? responseBody;
  final String? networkError;

  const ApplePurchaseVerificationDiagnostic.http({
    required this.statusCode,
    required this.responseBody,
  }) : networkError = null;

  const ApplePurchaseVerificationDiagnostic.networkError(this.networkError)
    : statusCode = null,
      responseBody = null;

  bool get isHttpResponse => statusCode != null;
}
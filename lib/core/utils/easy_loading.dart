import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/core/constants/strings.dart';

DateTime? _lastErrorTime;
String? _lastErrorMessage;

/// ===============================
/// CONFIGURATION
/// ===============================
void configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(seconds: 2)
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 40
    ..radius = 14
    ..progressColor = Colors.white
    ..backgroundColor = Colors.black.withOpacity(0.85)
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..maskColor = Colors.black.withOpacity(0.4)
    ..userInteractions = false
    ..dismissOnTap = true
    ..boxShadow = [];
}

/// ===============================
/// LOADING
/// ===============================
void showLoading({String? status}) {
  EasyLoading.show(
    status: status ?? "جاري التحميل...",
    maskType: EasyLoadingMaskType.black,
  );
}

void hideLoading() {
  if (EasyLoading.isShow) {
    EasyLoading.dismiss(animation: true);
  }
}

/// ===============================
/// ERROR
/// ===============================
void showError(String message) {
  final now = DateTime.now();
  if (_lastErrorMessage == message &&
      _lastErrorTime != null &&
      now.difference(_lastErrorTime!) < const Duration(seconds: 2)) {
    return;
  }
  _lastErrorMessage = message;
  _lastErrorTime = now;

  hideLoading();

  EasyLoading.showError(
    message,
    duration: const Duration(seconds: 2),
    dismissOnTap: true,
    maskType: EasyLoadingMaskType.black,
  );
}

/// ===============================
/// NO INTERNET ERROR
/// ===============================
void showNoInternetError([String? message]) {
  final msg = message ?? AppStrings.noInternetConnection;
  final now = DateTime.now();
  if (_lastErrorMessage == msg &&
      _lastErrorTime != null &&
      now.difference(_lastErrorTime!) < const Duration(seconds: 3)) {
    return;
  }
  _lastErrorMessage = msg;
  _lastErrorTime = now;

  hideLoading();

  EasyLoading.showError(
    msg,
    duration: const Duration(seconds: 3),
    dismissOnTap: true,
    maskType: EasyLoadingMaskType.none,
  );
}

/// ===============================
/// VERIFICATION DIAGNOSTIC
/// ===============================
void showVerificationDiagnostic(
  BuildContext context, {
  int? statusCode,
  String? responseBody,
  String? networkError,
  String? productId,
  String? targetType,
  int? contentId,
  String? signedTransaction,
}) {
  hideLoading();

  final responseText = responseBody ?? '';
  final bodyText = responseBody ?? networkError ?? 'No response body available';
  final responseCopyText =
      'HTTP Status Code: ${statusCode ?? 'unavailable'}\n\n'
      'Response Body:\n$responseText';
  var isSignedTransactionVisible = false;

  if (!context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.black.withOpacity(0.94),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 720,
              maxHeight: MediaQuery.sizeOf(context).height * 0.9,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white70),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Apple verification diagnostic',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        tooltip: 'Close diagnostic',
                        color: Colors.white,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _diagnosticSection(
                            context,
                            title: 'HTTP Response',
                            copyTooltip: 'Copy response',
                            copyValue: responseCopyText,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText(
                                  'HTTP Status Code: ${statusCode ?? 'unavailable'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Response Body',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 6),
                                SelectableText(
                                  bodyText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (productId != null)
                            _diagnosticSection(
                              context,
                              title: 'Product ID',
                              copyTooltip: 'Copy product ID',
                              copyValue: productId,
                              child: SelectableText(
                                productId,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          if (targetType != null || contentId != null)
                            _diagnosticSection(
                              context,
                              title: 'Purchase target',
                              copyTooltip: 'Copy target',
                              copyValue:
                                  'target type: ${targetType ?? 'unavailable'}\n'
                                  'contentId: ${contentId ?? 'unavailable'}',
                              child: SelectableText(
                                'target type: ${targetType ?? 'unavailable'}\n'
                                'contentId: ${contentId ?? 'unavailable'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          if (signedTransaction != null &&
                              signedTransaction.isNotEmpty)
                            _diagnosticSection(
                              context,
                              title: 'Apple signedTransaction',
                              copyTooltip: 'Copy signedTransaction',
                              copyValue: signedTransaction,
                              showCopyButton: false,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    onPressed: () => setState(
                                      () => isSignedTransactionVisible =
                                          !isSignedTransactionVisible,
                                    ),
                                    tooltip: isSignedTransactionVisible
                                        ? 'Hide signedTransaction'
                                        : 'Reveal signedTransaction',
                                    color: Colors.white,
                                    icon: Icon(
                                      isSignedTransactionVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                  ),
                                  if (isSignedTransactionVisible) ...[
                                    SelectableText(
                                      signedTransaction,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        height: 1.5,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        onPressed: () => _copyDiagnosticValue(
                                          context,
                                          signedTransaction,
                                          'signedTransaction copied',
                                        ),
                                        tooltip: 'Copy signedTransaction',
                                        color: Colors.white,
                                        icon: const Icon(Icons.copy),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _diagnosticSection(
  BuildContext context, {
  required String title,
  required String copyTooltip,
  required String copyValue,
  bool showCopyButton = true,
  required Widget child,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (showCopyButton)
              IconButton(
                onPressed: () =>
                    _copyDiagnosticValue(context, copyValue, '$title copied'),
                tooltip: copyTooltip,
                color: Colors.white,
                icon: const Icon(Icons.copy_all_rounded),
              ),
          ],
        ),
        child,
      ],
    ),
  );
}

void _copyDiagnosticValue(
  BuildContext context,
  String value,
  String confirmation,
) {
  Clipboard.setData(ClipboardData(text: value));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(confirmation), duration: const Duration(seconds: 2)),
  );
}

/// ===============================
/// SUCCESS
/// ===============================
void showSuccess(String message) {
  hideLoading();

  EasyLoading.showSuccess(
    message,
    duration: const Duration(seconds: 2),
    dismissOnTap: true,
    maskType: EasyLoadingMaskType.black,
  );
}

/// ===============================
/// INFO
/// ===============================
void showInfo(String message) {
  hideLoading();

  EasyLoading.showInfo(
    message,
    duration: const Duration(seconds: 2),
    dismissOnTap: true,
    maskType: EasyLoadingMaskType.black,
  );
}

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
}) {
  hideLoading();

  final httpStatus = statusCode != null ? 'HTTP $statusCode' : 'HTTP status unavailable';
  final bodyText = (responseBody ?? networkError ?? 'No response body available').trim();
  final copyText = [
    'HTTP status: ${statusCode ?? 'unavailable'}',
    '',
    'Response Body:',
    responseBody?.trim().isNotEmpty == true ? responseBody!.trim() : networkError ?? '',
  ].join('\n');

  if (!context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.black.withOpacity(0.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 520),
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
                      'Apple verification response',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: copyText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Response copied'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Copy Response',
                    color: Colors.white,
                    icon: const Icon(Icons.copy_all_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: SelectableText(
                  httpStatus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Response Body',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      bodyText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.7,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
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

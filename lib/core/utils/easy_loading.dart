import 'package:flutter/material.dart';
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

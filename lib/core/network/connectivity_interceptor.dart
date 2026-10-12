import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pythagoras/core/constants/strings.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';

/// Interceptor that automatically detects lack of internet connection
/// across all HTTP requests in the application and displays a professional
/// Arabic error notification without interfering with UI or cubit logic.
class ConnectivityInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (isConnectionError(err)) {
      showNoInternetError(AppStrings.noInternetConnection);
    }
    handler.next(err);
  }

  /// Checks whether a given [DioException] was caused by a connection or network failure.
  static bool isConnectionError(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout) {
      return true;
    }

    final error = err.error;
    if (error is SocketException) {
      return true;
    }

    final errString = error?.toString().toLowerCase() ?? '';
    final msgString = err.message?.toString().toLowerCase() ?? '';

    const indicators = [
      'socketexception',
      'failed host lookup',
      'network is unreachable',
      'no address associated with hostname',
      'connection refused',
      'connection reset',
      'network error',
      'no internet',
      'timed out',
      'software caused connection abort',
    ];

    for (final indicator in indicators) {
      if (errString.contains(indicator) || msgString.contains(indicator)) {
        return true;
      }
    }

    return false;
  }
}

import 'package:flutter/services.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/di/services_locator.dart';

class NativeDownloadService {
  static const MethodChannel _channel = MethodChannel('com.pythagoras.download/manager');

  Future<bool> enqueueDownload({
    required String url,
    required String title,
    required String fileName,
  }) async {
    try {
      final prefs = sl<PreferencesStorage>();
      final token = prefs.getUserToken();

      final result = await _channel.invokeMethod<bool>('download', {
        'url': url,
        'title': title,
        'fileName': fileName,
        'token': token,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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

      if (!kIsWeb && Platform.isIOS) {
        final downloadDio = Dio();
        if (token != null) {
          downloadDio.options.headers['Authorization'] = 'Bearer $token';
        }
        
        final tempDir = await getTemporaryDirectory();
        final savePath = '${tempDir.path}/$fileName';
        
        final response = await downloadDio.download(
          url,
          savePath,
          options: Options(
            responseType: ResponseType.bytes,
            validateStatus: (status) => status != null && status < 400,
          ),
        );
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          final file = File(savePath);
          if (await file.exists()) {
             await Share.shareXFiles([XFile(savePath)], subject: title);
             return true;
          }
        }
        return false;
      }

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

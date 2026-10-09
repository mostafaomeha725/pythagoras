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
          File file = File(savePath);
          if (await file.exists()) {
             String finalPath = savePath;
             final String? correctExt = _getExtensionFromHeaders(response.headers);
             String? mimeType = response.headers.value(Headers.contentTypeHeader)?.split(';').first.trim();
             
             if (correctExt != null && !finalPath.toLowerCase().endsWith(correctExt.toLowerCase())) {
                // If the file ends with a fake extension like .powerpoint or lacks an extension, replace it
                final pathWithoutFakeExt = finalPath.contains('.') 
                    ? finalPath.substring(0, finalPath.lastIndexOf('.'))
                    : finalPath;
                finalPath = '$pathWithoutFakeExt$correctExt';
                file = await file.rename(finalPath);
             }
             
             await Share.shareXFiles([XFile(finalPath, mimeType: mimeType)], subject: title);
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

  String? _getExtensionFromHeaders(Headers headers) {
    final contentDisposition = headers.value('content-disposition');
    if (contentDisposition != null) {
      final regex = RegExp(r'filename[^;=\n]*=((["'
          "'"
          r']).*?\2|[^;\n]*)');
      final match = regex.firstMatch(contentDisposition);
      if (match != null && match.groupCount >= 1) {
        String name = match.group(1)!.replaceAll('"', '').replaceAll("'", "");
        if (name.contains('.')) {
          return '.${name.split('.').last}';
        }
      }
    }
    
    final contentType = headers.value(Headers.contentTypeHeader);
    if (contentType != null) {
      final ct = contentType.toLowerCase();
      if (ct.contains('application/pdf')) return '.pdf';
      if (ct.contains('wordprocessingml.document')) return '.docx';
      if (ct.contains('msword')) return '.doc';
      if (ct.contains('presentationml.presentation')) return '.pptx';
      if (ct.contains('ms-powerpoint')) return '.ppt';
      if (ct.contains('spreadsheetml.sheet')) return '.xlsx';
      if (ct.contains('ms-excel')) return '.xls';
      if (ct.contains('image/jpeg')) return '.jpg';
      if (ct.contains('image/png')) return '.png';
      if (ct.contains('text/csv')) return '.csv';
      if (ct.contains('application/zip')) return '.zip';
    }
    return null;
  }
}

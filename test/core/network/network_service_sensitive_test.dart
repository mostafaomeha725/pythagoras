import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/network/network_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CapturingAdapter implements HttpClientAdapter {
  String? requestBody;
  int responseStatusCode = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final requestBytes = BytesBuilder();
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        requestBytes.add(chunk);
      }
    }
    requestBody = utf8.decode(requestBytes.takeBytes());
    return ResponseBody.fromString(
      '{"message":"accepted"}',
      responseStatusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    sl.registerSingleton<PreferencesStorage>(PreferencesStorage(preferences));
  });

  tearDown(() async {
    await sl.reset();
  });

  test(
    'sensitive POST sends exact proof without emitting it to Dio logs',
    () async {
      const signedTransaction = 'actual-storekit-server-verification-data';
      final adapter = _CapturingAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final networkService = NetworkService(dio);
      final originalDebugPrint = debugPrint;
      final logMessages = <String>[];
      debugPrint = (message, {wrapWidth}) {
        if (message != null) logMessages.add(message);
      };

      try {
        final result = await networkService.postSensitiveData(
          endPoint: 'api/iap/apple/verify',
          data: {'signedTransaction': signedTransaction},
        );
        expect(result.statusCode, 200);
      } finally {
        debugPrint = originalDebugPrint;
      }

      expect(jsonDecode(adapter.requestBody!) as Map<String, dynamic>, {
        'signedTransaction': signedTransaction,
      });
      expect(logMessages.join('\n'), isNot(contains(signedTransaction)));
    },
  );

  test('verification preserves each HTTP status without logging the body', () async {
    final adapter = _CapturingAdapter();
    final networkService = NetworkService(Dio()..httpClientAdapter = adapter);

    for (final statusCode in [200, 201, 204, 401, 403, 404, 422, 500]) {
      adapter.responseStatusCode = statusCode;
      final result = await networkService.postSensitiveData(
        endPoint: 'api/iap/apple/verify',
        data: const {'signedTransaction': 'actual-proof'},
      );

      expect(result.statusCode, statusCode);
      expect(result.isHttpResponse, isTrue);
    }
  });
}

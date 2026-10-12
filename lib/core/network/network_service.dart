import 'dart:convert';
import 'dart:io';

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/constants/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '/core/di/services_locator.dart';
import '/core/error/failure.dart';
import '/core/network/endpoints.dart';
import 'authorization_interceptor.dart';
import 'connectivity_interceptor.dart';

class NetworkService {
  final Dio dio;

  NetworkService(this.dio) {
    dio.options
      ..baseUrl = AppStrings.baseUrl
      // ResponseType.json: Dio auto-decompresses gzip and parses JSON
      ..responseType = ResponseType.json
      ..followRedirects = true
      ..receiveDataWhenStatusError = true
      ..connectTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30);

    addHeaders();
    addInterceptors();
  }

  void addInterceptors() {
    dio.interceptors.add(ConnectivityInterceptor());
    dio.interceptors.add(AuthorizationInterceptor());
    // if (isDevEnviroment()) {
    dio.interceptors.add(ChuckerDioInterceptor());
    dio.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        // Never log passwords or tokens in production
        logPrint: (object) => debugPrint(object.toString()),
      ),
    );
    // }
  }

  void addHeaders() {
    final prefs = sl<PreferencesStorage>();
    final token = prefs.getUserToken();
    dio.options.headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      // Do NOT set Accept-Encoding manually — Dart's HttpClient handles
      // gzip decompression automatically; setting it manually can cause
      // double-decompression issues with ResponseType.json
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  void addToken(String token) {
    dio.options.headers['Authorization'] = "Bearer $token";
  }

  void removeToken() {
    dio.options.headers.remove('Authorization');
  }

  Future<Either<Failure, dynamic>> postData({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    String? token,
    bool isRaw = true,
  }) async {
    try {
      final response = await dio.post(
        endPoint,
        data: data == null
            ? null
            : isRaw
            ? data
            : FormData.fromMap(data),
        queryParameters: queryParameters,
      );

      // responseType is json — Dio already decompressed & decoded the body
      final body = response.data;

      if (response.statusCode! >= 200 && response.statusCode! <= 299) {
        if (body is Map<String, dynamic> && body['status'] == false) {
          return Left(Failure(body['message']?.toString() ?? 'Request failed'));
        }
        return Right(body);
      } else {
        return Left(Failure(_extractMsgFromBody(body)));
      }
    } on SocketException {
      return const Left(Failure(AppStrings.noInternetConnection));
    } on FormatException {
      return const Left(Failure('استجابة السيرفر غير صالحة'));
    } on DioException catch (e) {
      return handleDioExceoptions(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  /// Extracts a user-friendly message from a JSON error body
  String _extractMsgFromBody(dynamic body) {
    if (body is! Map<String, dynamic>) return 'حدث خطأ غير متوقع';
    // errors as Map: {"errors": {"phone": ["..."]}}
    if (body['errors'] is Map) {
      for (final v in (body['errors'] as Map).values) {
        if (v is List && v.isNotEmpty) return v.first.toString();
      }
    }
    // errors as List: {"errors": [{"description": "..."}]}
    if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
      final first = (body['errors'] as List).first;
      if (first is Map<String, dynamic>) {
        if (first['code'] == 'EMAIL_NOT_VERIFIED') {
          return first['description']?.toString() ?? 'Email not verified';
        }
        return first['description']?.toString() ?? 'Unknown error';
      }
    }
    return body['message']?.toString() ??
        body['detail']?.toString() ??
        body['title']?.toString() ??
        'حدث خطأ';
  }

  Future<Either<Failure, dynamic>> postEncryptedData({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    String? token,
    bool isRaw = true,
  }) async {
    // Convert payload to JSON string
    String jsonPayload = jsonEncode(data);

    // Calculate HMAC SHA256 signature
    String signature = hmacSha256(jsonPayload);

    // Encode the signature as Base64
    String encodedSignature = base64.encode(utf8.encode(signature));

    dio.options.headers['X-Signature'] = encodedSignature;

    try {
      var response = await dio.post(
        endPoint,
        data: data == null
            ? null
            : isRaw
            ? data
            : FormData.fromMap(data),
        queryParameters: queryParameters,
      );

      if (response.statusCode! >= 200 && response.statusCode! <= 299) {
        return Right(response.data);
      } else {
        return Left(Failure(response.data['message'].toString()));
      }
    } on SocketException {
      return const Left(Failure(AppStrings.noInternetConnection));
    } on FormatException {
      return const Left(Failure("Format Exception"));
    } on DioException catch (e) {
      return handleDioExceoptions(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, dynamic>> uploadFile({
    required String endPoint,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      var response = await dio.post(
        endPoint,
        data: formData,
        queryParameters: queryParameters,
      );
      return Right(response.data);
    } on SocketException {
      return const Left(Failure(AppStrings.noInternetConnection));
    } on FormatException {
      return const Left(Failure("Format Exception"));
    } on DioException catch (e) {
      return handleDioExceoptions(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<String, dynamic>> downloadFile({
    required String fileUrl,
    required String savePath,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    dio.options.headers = {"Accept": "*/*"};

    try {
      var response = await dio.download(
        fileUrl,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: (received, total) {
          // You can use these values to show download progress
          // safePrint(
          //     'downloadFile =>Received: ${received.toString()}, Total: ${total.toString()}');

          if (total != -1) {
            // Calculate download progress percentage
            // double progress = (received / total * 100);
            // safePrint('downloadFile => progress: ${progress.toString()}}');
          }
        },
      );
      return Right(response);
    } catch (e) {
      debugPrint(e.toString());
      return Left(e.toString());
    }
  }

  Future<Either<Failure, dynamic>> putData({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      var response = await dio.put(
        endPoint,
        data: data,
        queryParameters: queryParameters,
      );
      return Right(response.data);
    } on SocketException {
      return const Left(Failure(AppStrings.noInternetConnection));
    } on FormatException {
      return const Left(Failure("Format Exception"));
    } on DioException catch (e) {
      return handleDioExceoptions(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<String, dynamic>> patchData({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    String? token,
    bool isRaw = true,
  }) async {
    try {
      var response = await dio.patch(
        endPoint,
        queryParameters: queryParameters,
        data: data == null
            ? null
            : isRaw
            ? data
            : FormData.fromMap(data),
      );
      return Right(response.data);
    } on SocketException {
      return const Left(AppStrings.noInternetConnection);
    } on FormatException {
      return const Left("Format Exception");
    } on DioException catch (e) {
      if (ConnectivityInterceptor.isConnectionError(e)) {
        return const Left(AppStrings.noInternetConnection);
      }
      if (e.type == DioExceptionType.badResponse) {
        final message = _extractErrorMessage(
          e.response?.data,
          fallback: e.message ?? 'Bad response',
        );
        return Left(message);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        return const Left(AppStrings.noInternetConnection);
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return const Left("انتهت مهلة الانتظار، حاول مرة أخرى");
      } else {
        return Left(e.message ?? "");
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, dynamic>> deleteData({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      var response = await dio.delete(
        endPoint,
        data: data,
        queryParameters: queryParameters,
      );
      return Right(response.data);
    } on SocketException {
      return const Left(AppStrings.noInternetConnection);
    } on FormatException {
      return const Left("Format Exception");
    } on DioException catch (e) {
      if (ConnectivityInterceptor.isConnectionError(e)) {
        return const Left(AppStrings.noInternetConnection);
      }
      if (e.type == DioExceptionType.badResponse) {
        final message = _extractErrorMessage(
          e.response?.data,
          fallback: e.message ?? 'Bad response',
        );
        return Left(message);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        return const Left(AppStrings.noInternetConnection);
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return const Left("انتهت مهلة الانتظار، حاول مرة أخرى");
      } else {
        return Left(e.message ?? "");
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<Failure, dynamic>> getData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      var response = await dio.get(endPoint, queryParameters: queryParameters);
      if (response.statusCode! >= 200 && response.statusCode! <= 299) {
        return Right(response.data);
      } else {
        final message = _extractErrorMessage(
          response.data,
          fallback: 'Error ${response.statusCode}',
        );
        return Left(Failure(message));
      }
    } on SocketException {
      return const Left(Failure(AppStrings.noInternetConnection));
    } on FormatException {
      return const Left(Failure("Format Exception"));
    } on DioException catch (e) {
      return handleDioExceoptions(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Left<Failure, dynamic> handleDioExceoptions(DioException e) {
    if (ConnectivityInterceptor.isConnectionError(e)) {
      return const Left(Failure(AppStrings.noInternetConnection));
    }
    if (e.type == DioExceptionType.badResponse) {
      final rawData = e.response?.data;
      Map<String, dynamic>? data;
      if (rawData is Map<String, dynamic>) {
        data = rawData;
      } else if (rawData is String && rawData.isNotEmpty) {
        try {
          data = jsonDecode(rawData) as Map<String, dynamic>?;
        } catch (_) {}
      }

      if (data != null) {
        // errors as Map: { "errors": { "phone": ["..."] } }
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          for (final fieldErrors in errors.values) {
            if (fieldErrors is List && fieldErrors.isNotEmpty) {
              return Left(Failure(fieldErrors.first.toString()));
            }
          }
        }
        // errors as List: { "errors": [{"description": "..."}] }
        if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
          final firstError = (data['errors'] as List).first;
          if (firstError is Map<String, dynamic>) {
            final desc =
                firstError['description']?.toString() ?? 'Unknown error';
            if (firstError['code'] == 'EMAIL_NOT_VERIFIED') {
              return Left(EmailNotVerifiedFailure(message: desc));
            }
            return Left(Failure(desc));
          }
        }
        if (data['detail'] != null) {
          return Left(Failure(data['detail'].toString()));
        }
        if (data['message'] != null) {
          return Left(Failure(data['message'].toString()));
        }
        if (data['title'] != null) {
          return Left(Failure(data['title'].toString()));
        }
      }
      return Left(Failure(e.message ?? 'Something went wrong'));
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return const Left(Failure(AppStrings.noInternetConnection));
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return const Left(Failure("انتهت مهلة الانتظار، حاول مرة أخرى"));
    } else {
      return Left(Failure(e.message ?? ""));
    }
  }

  String _extractErrorMessage(dynamic rawData, {required String fallback}) {
    Map<String, dynamic>? data;
    if (rawData is Map<String, dynamic>) {
      data = rawData;
    } else if (rawData is String && rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {}
    }

    if (data != null) {
      final errors = data['errors'];

      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is Map<String, dynamic>) {
          final description = first['description'];
          if (description is String && description.isNotEmpty) {
            return description;
          }
          final message = first['message'];
          if (message is String && message.isNotEmpty) {
            return message;
          }
        }
        if (first is String && first.isNotEmpty) {
          return first;
        }
      }

      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            final first = value.first;
            if (first is String && first.isNotEmpty) {
              return first;
            }
          }
          if (value is String && value.isNotEmpty) {
            return value;
          }
        }
      }

      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }

      final title = data['title'];
      if (title is String && title.isNotEmpty) {
        return title;
      }
    }

    return fallback;
  }

  String hmacSha256(String data) {
    var hmacSha256 = Hmac(
      sha256,
      utf8.encode(EndPoints.apiSecret),
    ); // HMAC-SHA256
    var digest = hmacSha256.convert(utf8.encode(data));
    return digest.toString();
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/core/network/endpoints.dart';
import 'package:pythagoras/core/network/network_service.dart';
import 'package:pythagoras/core/cache/hive_boxes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pythagoras/features/auth/domain/entities/register_response.dart';
import 'package:pythagoras/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final NetworkService networkService;
  final PreferencesStorage preferencesStorage;

  AuthRepositoryImpl({
    required this.networkService,
    required this.preferencesStorage,
  });

  @override
  Future<Either<Failure, void>> login(String phone, String password) async {
    final response = await networkService.postData(
      endPoint: EndPoints.login,
      data: {"phone": phone, "password": password},
    );

    return response.fold((failure) => Left(failure), (data) async {
      try {
        if (data is! Map<String, dynamic>) {
          return const Left(Failure('استجابة غير متوقعة من السيرفر'));
        }

        // API: { "success": true, "message": "...", "data": { "user": {...}, "token": "..." } }
        final success = data['success'];
        if (success == false) {
          final msg = data['message']?.toString() ?? 'فشل تسجيل الدخول';
          return Left(Failure(msg));
        }

        final dataMap = data['data'] as Map<String, dynamic>?;
        if (dataMap == null) {
          return const Left(Failure('بيانات الاستجابة غير صالحة'));
        }

        final token = dataMap['token'] as String?;
        final user = dataMap['user'] as Map<String, dynamic>?;

        if (token == null || token.isEmpty) {
          return const Left(Failure('لم يتم استلام رمز الدخول'));
        }

        // Clear previous user data and cache to start fresh
        await _clearLocalSessionData();

        await preferencesStorage.saveUserToken(token);
        networkService.addToken(token);

        if (user != null) {
          await preferencesStorage.saveUserProfile(jsonEncode(user));
          final userId = user['id'];
          if (userId != null) {
            await preferencesStorage.saveUserId(
              userId is int ? userId : int.tryParse(userId.toString()) ?? 0,
            );
          }
          final name = user['name'] as String?;
          if (name != null && name.isNotEmpty) {
            await preferencesStorage.saveUserName(name);
          }
        }

        debugPrint('✅ Login successful — user saved');
        return const Right(null);
      } catch (e) {
        debugPrint('🔴 AuthRepositoryImpl.login error: $e');
        return Left(Failure(e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, RegisterResponse>> register({
    required String name,
    required String phone,
    required String password,
    required int classId,
    String type = 'student',
  }) async {
    final response = await networkService.postData(
      endPoint: EndPoints.register,
      data: {
        "name": name,
        "phone": phone,
        "password": password,
        "class_id": classId,
        "type": type,
      },
    );

    return await response.fold<
      Future<Either<Failure, RegisterResponse>>
    >((failure) async => Left(failure), (data) async {
      try {
        if (data is! Map<String, dynamic>) {
          return const Left(Failure('استجابة غير متوقعة من السيرفر'));
        }

        final success = data['success'];
        if (success == false) {
          final msg = data['message']?.toString() ?? 'فشل إنشاء الحساب';
          return Left(Failure(msg));
        }

        final message = data['message']?.toString() ?? 'تم إنشاء الحساب بنجاح';
        final dataMap = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : (data['user'] is Map<String, dynamic> ? data : null);

        // Extract token from all possible locations
        String? token;
        if (dataMap != null) {
          token =
              (dataMap['token'] ??
                      dataMap['access_token'] ??
                      dataMap['authorisation']?['token'])
                  as String?;
        }
        token ??=
            (data['token'] ??
                    data['access_token'] ??
                    data['authorisation']?['token'])
                as String?;

        Map<String, dynamic>? user;
        if (dataMap != null && dataMap['user'] is Map<String, dynamic>) {
          user = dataMap['user'] as Map<String, dynamic>;
        } else if (data['user'] is Map<String, dynamic>) {
          user = data['user'] as Map<String, dynamic>;
        } else if (dataMap != null) {
          user = dataMap;
        }

        if (token != null && token.isNotEmpty) {
          await _clearLocalSessionData();
          await preferencesStorage.saveUserToken(token);
          networkService.addToken(token);
        } else {
          // Auto-login to establish session and get token if register didn't provide one
          debugPrint('🔄 Auto-logging in after register...');
          final loginResult = await login(phone, password);
          loginResult.fold(
            (failure) => debugPrint('⚠️ Auto-login failed: ${failure.message}'),
            (_) {
              token = preferencesStorage.getUserToken();
              debugPrint('✅ Auto-login succeeded, token: $token');
            },
          );
        }

        // Always save user identification and profile in PreferencesStorage
        final userId = user?['id'] ?? preferencesStorage.getUserId() ?? 0;
        final finalUserId = userId is int
            ? userId
            : int.tryParse(userId.toString()) ?? 0;
        if (finalUserId != 0) {
          await preferencesStorage.saveUserId(finalUserId);
        }

        final userName = (user?['name'] as String?)?.isNotEmpty == true
            ? user!['name'] as String
            : name;
        await preferencesStorage.saveUserName(userName);

        final profileMap = <String, dynamic>{
          if (user != null) ...user,
          'id': finalUserId,
          'name': userName,
          'phone': phone,
          'class_id': user?['class_id'] ?? classId,
          'role': 'student',
          'type': type,
        };
        await preferencesStorage.saveUserProfile(jsonEncode(profileMap));

        debugPrint(
          '✅ Registered student session ready: $userName (id: $finalUserId, class: $classId)',
        );

        return Right(
          RegisterResponse(
            success: true,
            message: message,
            token: token ?? preferencesStorage.getUserToken(),
            user: profileMap,
          ),
        );
      } catch (e) {
        debugPrint('🔴 AuthRepositoryImpl.register error: $e');
        return Left(Failure(e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // Always clear the local session first, regardless of server response.
    // This prevents the user from being trapped if the token is already expired
    // (401) or the server times out.
    await _clearLocalSessionData();

    // Best-effort: notify the server to invalidate the token.
    // We intentionally ignore any error here because the local session is
    // already clean and the user is effectively logged out.
    try {
      await networkService.postData(endPoint: EndPoints.logout);
    } catch (_) {}

    return const Right(null);
  }

  Future<void> _clearLocalSessionData() async {
    await preferencesStorage.clearUserSessionData();
    networkService.removeToken();
    try {
      await Hive.box(HiveBoxes.cacheBox).clear();
    } catch (_) {}
  }

  @override
  Future<Either<Failure, String>> getWhatsappRegisterUrl() async {
    final response = await networkService.getData(
      endPoint: EndPoints.registerWhatsapp,
    );

    return response.fold((failure) => Left(failure), (data) {
      try {
        if (data is Map<String, dynamic> && data.containsKey('whatsappUrl')) {
          return Right(data['whatsappUrl'] as String);
        }
        return const Left(Failure('استجابة غير متوقعة من السيرفر'));
      } catch (e) {
        debugPrint('🔴 AuthRepositoryImpl.getWhatsappRegisterUrl error: $e');
        return Left(Failure(e.toString()));
      }
    });
  }
}

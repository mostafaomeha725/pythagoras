import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/core/network/endpoints.dart';
import 'package:pythagoras/core/network/network_service.dart';
import 'package:pythagoras/core/cache/hive_boxes.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
      data: {
        "phone": phone,
        "password": password, // never printed in release
      },
    );

    return response.fold(
      (failure) => Left(failure),
      (data) async {
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
              await preferencesStorage.saveUserId(userId is int ? userId : int.tryParse(userId.toString()) ?? 0);
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
      },
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    final response = await networkService.postData(
      endPoint: EndPoints.logout,
    );

    return response.fold(
      (failure) async {
        // Handle 401 or session revoked
        if (failure.message.contains('401') || failure.message.contains('SESSION_REVOKED')) {
          await _clearLocalSessionData();
          return const Right(null);
        }
        return Left(failure);
      },
      (data) async {
        try {
          if (data is Map<String, dynamic> && data['success'] == true) {
            await _clearLocalSessionData();
            return const Right(null);
          }
          return const Left(Failure('استجابة غير متوقعة عند تسجيل الخروج'));
        } catch (e) {
          debugPrint('🔴 AuthRepositoryImpl.logout error: $e');
          return Left(Failure(e.toString()));
        }
      },
    );
  }

  Future<void> _clearLocalSessionData() async {
    await preferencesStorage.clear();
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

    return response.fold(
      (failure) => Left(failure),
      (data) {
        try {
          if (data is Map<String, dynamic> && data.containsKey('whatsappUrl')) {
            return Right(data['whatsappUrl'] as String);
          }
          return const Left(Failure('استجابة غير متوقعة من السيرفر'));
        } catch (e) {
          debugPrint('🔴 AuthRepositoryImpl.getWhatsappRegisterUrl error: $e');
          return Left(Failure(e.toString()));
        }
      },
    );
  }
}

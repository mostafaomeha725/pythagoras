import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/core/network/endpoints.dart';
import 'package:pythagoras/core/network/network_service.dart';
import 'package:pythagoras/features/profile/data/models/user_profile_model.dart';
import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';
import 'package:pythagoras/features/profile/data/models/my_course_enrollment_model.dart';
import 'package:pythagoras/features/profile/domain/entities/my_course_enrollment.dart';
import 'package:pythagoras/features/profile/domain/repositories/profile_repository.dart';
import 'package:pythagoras/core/enums/app_enums.dart';
import 'package:pythagoras/core/cache/hive_storage.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final NetworkService networkService;
  final PreferencesStorage preferencesStorage;
  final CacheService cacheService;

  ProfileRepositoryImpl({
    required this.networkService,
    required this.preferencesStorage,
    required this.cacheService,
  });

  @override
  Future<Either<Failure, UserProfile>> getAccountInfo({
    bool fromCache = false,
  }) async {
    final cacheKey = PreferencesKeys.cachedAccountInfo.name;

    if (fromCache) {
      final cachedString = cacheService.getString(cacheKey);
      if (cachedString != null && cachedString.isNotEmpty) {
        final Map<String, dynamic> user = json.decode(cachedString);
        return Right(UserProfileModel.fromJson(user));
      } else {
        return Left(Failure('No cached data'));
      }
    }

    final response = await networkService.getData(endPoint: EndPoints.account);

    return response.fold(
      (failure) async {
        if (failure.message.contains('401') ||
            failure.message.contains('SESSION_REVOKED')) {
          await _clearLocalSessionData();
          return Left(Failure('SESSION_EXPIRED'));
        }
        return Left(failure);
      },
      (data) async {
        try {
          if (data is! Map<String, dynamic>) {
            return const Left(Failure('استجابة غير متوقعة من السيرفر'));
          }

          final success = data['success'];
          if (success == false) {
            final msg =
                data['message']?.toString() ?? 'فشل في جلب بيانات الحساب';
            return Left(Failure(msg));
          }

          final dataMap = data['data'] as Map<String, dynamic>?;
          if (dataMap == null) {
            return const Left(Failure('بيانات الاستجابة غير صالحة'));
          }

          final user = dataMap['user'] as Map<String, dynamic>?;
          if (user == null) {
            return const Left(Failure('بيانات المستخدم غير موجودة'));
          }

          // Merge role if it's outside user object but needed in model
          final role = dataMap['role'] as String?;
          if (role != null) {
            user['role'] = role;
          }

          final userProfile = UserProfileModel.fromJson(user);

          // Update local cache
          cacheService.saveString(
            PreferencesKeys.cachedAccountInfo.name,
            jsonEncode(user),
          );
          await preferencesStorage.saveUserProfile(jsonEncode(user));
          await preferencesStorage.saveUserId(userProfile.id);
          await preferencesStorage.saveUserName(userProfile.name);

          return Right(userProfile);
        } catch (e) {
          debugPrint('🔴 ProfileRepositoryImpl.getAccountInfo error: $e');
          return Left(Failure(e.toString()));
        }
      },
    );
  }

  Future<void> _clearLocalSessionData() async {
    await preferencesStorage.deleteUserToken();
    await preferencesStorage.deleteUserProfile();
    await preferencesStorage.deleteUserId();
    networkService.removeToken();
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(File image) async {
    try {
      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path, filename: fileName),
      });

      final response = await networkService.uploadFile(
        endPoint: EndPoints.uploadProfilePicture,
        formData: formData,
      );

      return response.fold((failure) => Left(failure), (data) {
        if (data['success'] == true) {
          final url = data['data']['profile_picture_url'] as String;
          return Right(url);
        } else {
          return Left(
            Failure(data['message']?.toString() ?? 'فشل في رفع الصورة'),
          );
        }
      });
    } catch (e) {
      debugPrint('🔴 ProfileRepositoryImpl.uploadProfilePicture error: $e');
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updatePersonalProfile({
    required String name,
    String? password,
  }) async {
    try {
      final data = {'name': name};
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }

      final response = await networkService.putData(
        endPoint: EndPoints.updatePersonalProfile,
        data: data,
      );

      return response.fold((failure) => Left(failure), (responseData) async {
        if (responseData != null && responseData['success'] == true) {
          final dataMap = responseData['data'] as Map<String, dynamic>;
          final user = dataMap['user'] as Map<String, dynamic>;
          final role = dataMap['role'] as String?;
          if (role != null) {
            user['role'] = role;
          }

          final userProfile = UserProfileModel.fromJson(user);

          // Update local cache
          await preferencesStorage.saveUserProfile(jsonEncode(user));
          await preferencesStorage.saveUserName(userProfile.name);

          return Right(userProfile);
        } else {
          return Left(
            Failure(
              responseData?['message']?.toString() ??
                  'فشل في تحديث بيانات الحساب',
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('🔴 ProfileRepositoryImpl.updatePersonalProfile error: $e');
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MyCourseEnrollment>>> getMyCourses({
    bool fromCache = false,
  }) async {
    try {
      final cacheKey = PreferencesKeys.cachedMyCourses.name;

      if (fromCache) {
        final cachedString = cacheService.getString(cacheKey);
        if (cachedString != null && cachedString.isNotEmpty) {
          final List<dynamic> dataList = json.decode(cachedString);
          final enrollments = dataList
              .map((json) => MyCourseEnrollmentModel.fromJson(json))
              .toList();
          return Right(enrollments);
        } else {
          return Left(Failure('No cached data'));
        }
      }

      final response = await networkService.getData(
        endPoint: EndPoints.myCourses,
      );

      return response.fold((failure) => Left(failure), (responseData) async {
        if (responseData != null && responseData['success'] == true) {
          final List<dynamic> dataList = responseData['data'] ?? [];

          await cacheService.saveString(cacheKey, json.encode(dataList));

          final enrollments = dataList
              .map((json) => MyCourseEnrollmentModel.fromJson(json))
              .toList();
          return Right(enrollments);
        } else {
          return Left(
            Failure(
              responseData?['message']?.toString() ?? 'فشل في جلب الدوراتي',
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('🔴 ProfileRepositoryImpl.getMyCourses error: $e');
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> submitContactUs({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      final response = await networkService.postData(
        endPoint: EndPoints.contact,
        data: {'name': name, 'email': email, 'message': message},
      );

      return response.fold((failure) => Left(failure), (responseData) {
        if (responseData != null && responseData['success'] == true) {
          final msg =
              responseData['message']?.toString() ?? 'تم إرسال الرسالة بنجاح.';
          return Right(msg);
        } else {
          return Left(
            Failure(
              responseData?['message']?.toString() ?? 'فشل في إرسال الرسالة',
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('🔴 ProfileRepositoryImpl.submitContactUs error: $e');
      return Left(Failure(e.toString()));
    }
  }
}

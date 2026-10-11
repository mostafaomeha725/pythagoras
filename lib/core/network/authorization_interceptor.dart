import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:dio/dio.dart';
import '/core/di/services_locator.dart';
import 'package:pythagoras/core/routes/app_routes.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_cubit.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/core/cache/hive_storage.dart';
import 'endpoints.dart';
import 'network_service.dart';

class AuthorizationInterceptor extends Interceptor {
  bool _isHandlingSessionExpired = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = sl<PreferencesStorage>();

    final token = prefs.getUserToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = "Bearer $token";
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 || _isSessionExpiredResponse(err)) {
      _process401(err);
    }
    handler.next(err);
  }

  bool _isSessionExpiredResponse(DioException err) {
    final data = err.response?.data;
    if (data is Map) {
      final msg = data['message']?.toString().toLowerCase() ?? '';
      return msg.contains('unauthenticated') || msg.contains('session_revoked');
    } else if (data is String) {
      final lower = data.toLowerCase();
      return lower.contains('unauthenticated') ||
          lower.contains('session_revoked');
    }
    return false;
  }

  void _process401(DioException err) {
    // 1. Do not treat 401 on login as an expired existing session
    final path = err.requestOptions.path;
    if (path.contains(EndPoints.login)) {
      return;
    }

    // 2. Check if the request was authenticated with a Bearer token
    final authHeader = err.requestOptions.headers['Authorization'] as String?;
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return;
    }

    final requestToken = authHeader.substring(7).trim();
    final prefs = sl<PreferencesStorage>();
    final currentToken = prefs.getUserToken();

    // 3. Do not wipe new session if this 401 was from an old/stale token or user already logged out
    if (currentToken == null ||
        currentToken.isEmpty ||
        requestToken != currentToken) {
      return;
    }

    // 4. Prevent concurrent multiple executions of session expiration
    if (_isHandlingSessionExpired) {
      return;
    }
    _isHandlingSessionExpired = true;

    _handleSessionExpired().whenComplete(() {
      _isHandlingSessionExpired = false;
    });
  }

  Future<void> _handleSessionExpired() async {
    try {
      final prefs = sl<PreferencesStorage>();
      await prefs.clearUserSessionData();

      // Clear the token from the live Dio instance immediately
      try {
        final networkService = sl<NetworkService>();
        networkService.removeToken();
      } catch (_) {}

      try {
        final cache = sl<CacheService>();
        await cache.clear();
      } catch (_) {}

      hideLoading();

      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        try {
          context.read<ProfileCubit>().resetProfile();
        } catch (_) {}

        try {
          final coursesCubit = context.read<CoursesListCubit>();
          coursesCubit.resetCourses();
          coursesCubit.fetchCourses();
        } catch (_) {}

        try {
          final classesCubit = context.read<ClassesCubit>();
          classesCubit.resetClasses();
          classesCubit.fetchClasses();
        } catch (_) {}

        try {
          context.go(Routes.mainNavigationScreen);
        } catch (_) {}

        showError('انتهت صلاحية جلستك، يرجى تسجيل الدخول مرة أخرى.');
      }
    } catch (_) {}
  }
}

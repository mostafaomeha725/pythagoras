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

class AuthorizationInterceptor extends Interceptor {
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
    if (err.response?.statusCode == 401) {
      final data = err.response?.data;
      String message = '';
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }
      
      if (message.contains('تسجيل خروجك') || message.contains('جهاز آخر')) {
        _handleGlobalLogout(message);
      }
    }
    handler.next(err);
  }

  Future<void> _handleGlobalLogout(String message) async {
    try {
      final prefs = sl<PreferencesStorage>();
      await prefs.clear();
      
      try {
        final cache = sl<CacheService>();
        await cache.clear();
      } catch (_) {}
      
      final context = navigatorKey.currentContext;
      if (context != null) {
        if (context.mounted) {
          context.read<ProfileCubit>().resetProfile();
          
          final coursesCubit = context.read<CoursesListCubit>();
          coursesCubit.resetCourses();
          coursesCubit.fetchCourses();
          
          final classesCubit = context.read<ClassesCubit>();
          classesCubit.resetClasses();
          classesCubit.fetchClasses();
          
          context.go(Routes.mainNavigationScreen);
        }
      }
      
      showError('تم تسجيل خروجك لأن الحساب تم تسجيل دخوله على جهاز آخر.');
    } catch (_) {}
  }
}

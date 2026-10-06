import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/auth/presentation/widgets/auth_bottom_sheet.dart';

class AuthGuard {
  /// Checks if the user is authenticated. If so, executes the [action].
  /// If not, shows a bottom sheet asking them to login. If they login successfully,
  /// it will return to the previous screen and execute the [action].
  static Future<bool> checkAuthAndExecute(
    BuildContext context,
    FutureOr<void> Function() action,
  ) async {
    final prefs = sl<PreferencesStorage>();
    final token = prefs.getUserToken();

    if (token != null && token.isNotEmpty) {
      await action();
      return false; // Already logged in
    } else {
      final result = await AuthBottomSheet.show(context);
      if (result == true) {
        // User logged in successfully
        if (context.mounted) {
          // Re-fetch global data for the new user
          context.read<ProfileCubit>().getAccountInfo();
          context.read<CoursesListCubit>().fetchCourses();
          
          await action();
        }
        return true; // New login occurred
      }
      return false; // Login cancelled
    }
  }
}

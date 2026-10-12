import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/utils/class_name_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = sl<PreferencesStorage>();
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final token = prefs.getUserToken();
        final isGuest = token == null || token.isEmpty;

        String fullName = isGuest ? 'يا زائر' : (prefs.getUserName() ?? 'طالب');
        String branchName = isGuest ? 'تصفح كورساتنا الآن' : (prefs.getBranchName() ?? 'طالبنا المميز');
        int? classId;

        // Fallback to cached preferences
        final profileJson = prefs.getUserProfile();
        if (profileJson != null) {
          try {
            final userMap = jsonDecode(profileJson);
            classId = userMap['class_id'];
          } catch (_) {}
        }

        // Override with loaded state if available
        if (state is ProfileLoaded && !isGuest) {
          fullName = state.userProfile.name;
          if (state.userProfile.classId != null) {
            classId = state.userProfile.classId;
          }
        }

        String displaySubtitle = branchName;
        if (classId != null) {
          displaySubtitle = ClassNameHelper.getClassName(classId) ?? branchName;
        }

        return Padding(
          padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Greeting and Grade
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "أهلاً $fullName",
                      style: font20w700.copyWith(color: const Color(0xFF1E1E2D)),
                    ),
                    AppText(
                      displaySubtitle,
                      style: font14w600.copyWith(color: AppLightColors.primary),
                    ),
                  ],
                ),
              ),

              // Avatars / Icons
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppLightColors.primary, width: 1.5.w),
                      boxShadow: [
                        BoxShadow(
                          color: AppLightColors.primary.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Image.asset(
                          'assets/logoapp.jpeg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

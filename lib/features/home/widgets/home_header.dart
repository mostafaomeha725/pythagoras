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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pythagoras/core/constants/strings.dart';
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
        String? avatarUrl;
        int? classId;

        // Fallback to cached preferences
        final profileJson = prefs.getUserProfile();
        if (profileJson != null) {
          try {
            final userMap = jsonDecode(profileJson);
            avatarUrl = userMap['profile_picture_url'] ??
                userMap['avatar_url'] ??
                userMap['avatar'] ??
                userMap['image'];
            classId = userMap['class_id'];
          } catch (_) {}
        }

        // Override with loaded state if available
        if (state is ProfileLoaded && !isGuest) {
          fullName = state.userProfile.name;
          if (state.userProfile.profilePictureUrl != null &&
              state.userProfile.profilePictureUrl!.isNotEmpty) {
            avatarUrl = state.userProfile.profilePictureUrl;
          }
          if (state.userProfile.classId != null) {
            classId = state.userProfile.classId;
          }
        }

        if (avatarUrl != null && !avatarUrl.startsWith('http')) {
          avatarUrl = '${AppStrings.baseUrl}$avatarUrl';
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
                  if (avatarUrl != null && avatarUrl.isNotEmpty)
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppLightColors.primary, width: 1.w),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: avatarUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Center(
                            child: Text("👨‍🎓", style: TextStyle(fontSize: 20.sp)),
                          ),
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: AppLightColors.primary,
                              strokeWidth: 2.w,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFCEEFA),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text("👨‍🎓", style: TextStyle(fontSize: 20.sp)),
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/utils/class_name_helper.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = sl<PreferencesStorage>();
    final String fullName = prefs.getUserName() ?? 'طالب';
    final String branchName = prefs.getBranchName() ?? 'طالبنا المميز';

    String? avatarUrl;
    int? classId;
    final profileJson = prefs.getUserProfile();
    if (profileJson != null) {
      try {
        final userMap = jsonDecode(profileJson);
        avatarUrl =
            userMap['avatar_url'] ?? userMap['avatar'] ?? userMap['image'];
        classId = userMap['class_id'];
      } catch (_) {}
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
                    image: DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
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
  }
}


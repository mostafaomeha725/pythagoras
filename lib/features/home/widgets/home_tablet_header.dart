import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/class_name_helper.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_state.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_state.dart';

/// Top header banner for Home screen customized for Tablet Landscape.
/// Uses fixed pixel values to avoid ScreenUtil distortion.
class HomeTabletHeader extends StatelessWidget {
  const HomeTabletHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = sl<PreferencesStorage>();

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        return BlocBuilder<ClassesCubit, ClassesState>(
          builder: (context, classesState) {
            final token = prefs.getUserToken();
            final isGuest = token == null || token.isEmpty;

            String fullName = isGuest
                ? 'يا زائر'
                : (prefs.getUserName() ?? 'طالب');
            String branchName = isGuest
                ? 'تصفح كورساتنا الآن'
                : (prefs.getBranchName() ?? 'طالبنا المميز');
            int? classId;

            final profileJson = prefs.getUserProfile();
            if (profileJson != null) {
              try {
                final userMap = jsonDecode(profileJson);
                classId = userMap['class_id'];
              } catch (_) {}
            }

            if (profileState is ProfileLoaded && !isGuest) {
              fullName = profileState.userProfile.name;
              if (profileState.userProfile.classId != null) {
                classId = profileState.userProfile.classId;
              }
            }

            String displaySubtitle = branchName;
            if (classId != null) {
              List<StudentClass>? dynamicClasses;
              if (classesState is ClassesLoaded) {
                dynamicClasses = classesState.classes
                    .where((c) => c.id != 0)
                    .toList();
              }

              displaySubtitle =
                  ClassNameHelper.getClassName(
                    classId,
                    classes: dynamicClasses,
                  ) ??
                  branchName;
            }

            return Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          "أهلاً $fullName",
                          style: font20w700.copyWith(
                            color: const Color(0xFF1E1E2D),
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          displaySubtitle,
                          style: font14w600.copyWith(
                            color: AppLightColors.primary,
                            fontSize: 14.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: AppLightColors.primary,
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppLightColors.primary.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Image.asset(
                          'assets/logoapp.jpeg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

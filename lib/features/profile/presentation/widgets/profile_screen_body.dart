import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/features/profile/domain/entities/profile_option.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_state.dart';
import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_option_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/logout_dialog.dart';
import 'package:pythagoras/features/profile/presentation/widgets/delete_account_dialog.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_shimmer.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_tablet_landscape.dart';

class ProfileScreenBody extends StatelessWidget {
  const ProfileScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileFailure) {
          if (state.isSessionExpired) {
            context.read<ProfileCubit>().resetProfile();
            final coursesCubit = context.read<CoursesListCubit>();
            coursesCubit.resetCourses();
            coursesCubit.fetchCourses();

            context.go(Routes.mainNavigationScreen);
            showError('انتهت صلاحية جلستك، يرجى تسجيل الدخول مرة أخرى.');
          } else {
            showError(state.message);
          }
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading && state is! ProfileLoaded) {
          return const ProfileShimmer();
        }

        final prefs = sl<PreferencesStorage>();
        final token = prefs.getUserToken();
        final isGuest = token == null || token.isEmpty;

        String name = isGuest ? 'يا زائر  ' : 'جارٍ التحميل...';
        String grade = isGuest ? 'سجل الدخول للمزيد من الميزات' : '';
        String? profilePictureUrl;
        UserProfile? currentUserProfile;

        if (state is ProfileLoaded && !isGuest) {
          name = state.userProfile.name;
          grade = state.userProfile.phone; // Using phone or role as subtitle
          profilePictureUrl = state.userProfile.profilePictureUrl;
          currentUserProfile = state.userProfile;
        }

        List<ProfileOption> options = [];

        if (isGuest) {
          options = [
            ProfileOption(
              title: 'تسجيل الدخول',
              subtitle: 'سجل الدخول للاستمتاع بكافة الميزات',
              icon: Icons.login_outlined,
              onTap: () async {
                final result = await context.push(
                  Routes.loginScreen,
                  extra: true,
                );
                if (result == true && context.mounted) {
                  final token = sl<PreferencesStorage>().getUserToken();
                  if (token != null && token.isNotEmpty) {
                    context.read<ProfileCubit>().getAccountInfo();
                    context.read<CoursesListCubit>().fetchCourses();
                  }
                }
              },
            ),
            // ProfileOption(
            //   title: 'تواصل معنا',
            //   subtitle: 'الدعم والمساعدة',
            //   icon: Icons.support_agent_outlined,
            //   onTap: () => context.push(Routes.contactUsScreen),
            // ),
            ProfileOption(
              title: 'سياسة الخصوصية',
              subtitle: 'شروط الخصوصية وأمان البيانات',
              icon: Icons.privacy_tip_outlined,
              onTap: () => context.push(Routes.privacyPolicyScreen),
            ),
          ];
        } else {
          options = [
            ProfileOption(
              title: 'تعديل الملف الشخصي',
              icon: Icons.edit_outlined,
              onTap: () async {
                final result = await context.push(
                  Routes.editProfileScreen,
                  extra: currentUserProfile,
                );
                if (result == true && context.mounted) {
                  context.read<ProfileCubit>().getAccountInfo();
                }
              },
            ),
            ProfileOption(
              title: 'دوراتي',
              subtitle: 'عرض الدورات المشترك بها',
              icon: Icons.menu_book_outlined,
              onTap: () => context.push(Routes.myCoursesScreen),
            ),
            // ProfileOption(
            //   title: 'تواصل معنا',
            //   subtitle: 'الدعم والمساعدة',
            //   icon: Icons.support_agent_outlined,
            //   onTap: () => context.push(Routes.contactUsScreen),
            // ),
            ProfileOption(
              title: 'سياسة الخصوصية',
              subtitle: 'شروط الخصوصية وأمان البيانات',
              icon: Icons.privacy_tip_outlined,
              onTap: () => context.push(Routes.privacyPolicyScreen),
            ),
            ProfileOption(
              title: 'حذف الحساب',
              subtitle: 'حذف حسابك وبياناتك نهائياً',
              icon: Icons.delete_outline_rounded,
              isDestructive: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const DeleteAccountDialog(),
                );
              },
            ),
            ProfileOption(
              title: 'تسجيل الخروج',
              icon: Icons.logout_outlined,
              isDestructive: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const LogoutDialog(),
                );
              },
            ),
          ];
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet =
                ResponsiveHelper.isTablet(context) ||
                (constraints.maxWidth >= 900 &&
                    constraints.maxWidth > constraints.maxHeight);

            if (isTablet) {
              final isPortrait = ResponsiveHelper.isPortrait(
                context,
                constraints,
              );
              return ProfileTabletLandscape(
                name: name,
                grade: grade,
                profilePictureUrl: profilePictureUrl,
                options: options,
                bottomPadding: isPortrait ? 110 : 24,
                onRefresh: () async {
                  if (!isGuest) {
                    await context.read<ProfileCubit>().getAccountInfo();
                  }
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (!isGuest) {
                  await context.read<ProfileCubit>().getAccountInfo();
                }
              },
              color: const Color(0xFF832561),
              child: ListView(
                padding: EdgeInsets.all(24.w),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  ProfileHeaderCard(
                    name: name,
                    grade: grade,
                    profilePictureUrl: profilePictureUrl,
                  ),
                  SizedBox(height: 32.h),
                  ...options.map((option) => ProfileOptionCard(option: option)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

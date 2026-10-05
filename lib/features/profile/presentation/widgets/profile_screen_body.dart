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

class ProfileScreenBody extends StatelessWidget {
  const ProfileScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileFailure) {
          if (state.isSessionExpired) {
            context.go(Routes.chooseUserTypeScreen);
          } else {
            showError(state.message);
          }
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading && state is! ProfileLoaded) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF832561)));
        }
        
        String name = 'جارٍ التحميل...';
        String grade = '';
        String? profilePictureUrl;
        UserProfile? currentUserProfile;

        if (state is ProfileLoaded) {
          name = state.userProfile.name;
          grade = state.userProfile.phone; // Using phone or role as subtitle 
          profilePictureUrl = state.userProfile.profilePictureUrl;
          currentUserProfile = state.userProfile;
        }

        final List<ProfileOption> options = [
          ProfileOption(
            title: 'تعديل الملف الشخصي',
            icon: Icons.edit_outlined,
            onTap: () async {
              final result = await context.push(Routes.editProfileScreen, extra: currentUserProfile);
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
          ProfileOption(
            title: 'تواصل معنا',
            subtitle: 'الدعم والمساعدة',
            icon: Icons.menu_book_outlined,
            onTap: () => context.push(Routes.contactUsScreen),
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

        return RefreshIndicator(
          onRefresh: () => context.read<ProfileCubit>().getAccountInfo(),
          color: const Color(0xFF832561),
          child: ListView(
            padding: EdgeInsets.all(24.w),
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
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
  }
}

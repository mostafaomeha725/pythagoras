import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/logout_state.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LogoutCubit>(),
      child: BlocConsumer<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state is LogoutLoading) {
            showLoading();
          } else if (state is LogoutSuccess) {
            hideLoading();
            showSuccess('تم تسجيل الخروج بنجاح');
            
            // Reset state to Guest
            context.read<ProfileCubit>().resetProfile();
            context.read<CoursesListCubit>().fetchCourses();

            // Just close the dialog, staying on the same page
            context.pop();
          } else if (state is LogoutFailure) {
            hideLoading();
            showError(state.message);
          }
        },
        builder: (context, state) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Red Icon with light red background
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF2F2), // Light red background
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: const Color(0xFFEF4444), // Red color
                      size: 28.w,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Title
                  AppText(
                    'هل تريد تسجيل الخروج؟',
                    style: font18w700.copyWith(color: const Color(0xFF1E1E2D)),
                    alignment: AlignmentDirectional.center,
                  ),
                  SizedBox(height: 8.h),

                  // Subtitle
                  AppText(
                    'سيتم إنهاء جلستك الحالية سريعا.',
                    style: font12w500.copyWith(color: const Color(0xFF6B7280)),
                    alignment: AlignmentDirectional.center,
                  ),
                  SizedBox(height: 24.h),

                  // Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: BounceIt(
                          onPressed: () {
                            if (state is! LogoutLoading) {
                              context.pop();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            alignment: Alignment.center,
                            child: AppText(
                              'إلغاء',
                              style: font14w600.copyWith(
                                color: const Color(0xFF4B5563),
                              ),
                              alignment: AlignmentDirectional.center,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: BounceIt(
                          onPressed: () {
                            if (state is! LogoutLoading) {
                              context.read<LogoutCubit>().logout();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              color: AppLightColors.primary,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            alignment: Alignment.center,
                            child: AppText(
                              'تسجيل الخروج',
                              style: font14w600.copyWith(color: Colors.white),
                              alignment: AlignmentDirectional.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/delete_account/delete_account_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/delete_account/delete_account_state.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';

import 'package:pythagoras/features/profile/presentation/widgets/delete_account_tablet_dialog.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeleteAccountCubit>(),
      child: BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
        listener: (context, state) {
          if (state is DeleteAccountLoading) {
            showLoading();
          } else if (state is DeleteAccountSuccess) {
            hideLoading();
            showSuccess('تم حذف الحساب بنجاح');

            // Reset state to Guest across the app
            context.read<ProfileCubit>().resetProfile();
            final coursesCubit = context.read<CoursesListCubit>();
            coursesCubit.resetCourses();
            coursesCubit.fetchCourses();

            // Close the dialog and return to main navigation screen
            context.pop();
            context.go(Routes.mainNavigationScreen);
          } else if (state is DeleteAccountFailure) {
            hideLoading();
            showError(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is DeleteAccountLoading;
          final size = MediaQuery.sizeOf(context);
          final isTabletLandscape =
              size.width >= 900 &&
              size.height >= 600 &&
              size.width > size.height;

          if (isTabletLandscape) {
            return DeleteAccountTabletDialog(
              isLoading: isLoading,
              onConfirm: () =>
                  context.read<DeleteAccountCubit>().deleteAccount(),
              onCancel: () => context.pop(),
            );
          }

          final isTablet = size.width >= 600;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isTablet ? 20 : 24.r),
            ),
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 40 : 24.w,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 440 : double.infinity,
              ),
              child: Padding(
                padding: isTablet
                    ? const EdgeInsets.all(24)
                    : EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Red Trash / Person Remove Icon with soft red background
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF2F2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_forever_rounded,
                        color: const Color(0xFFDC2626),
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // Title
                    AppText(
                      'حذف الحساب نهائياً',
                      style: font18w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                      ),
                      alignment: AlignmentDirectional.center,
                    ),
                    SizedBox(height: 8.h),

                    // Subtitle
                    AppText(
                      'هل أنت متأكد من رغبتك في حذف حسابك؟',
                      style: font14w500.copyWith(
                        color: const Color(0xFF4B5563),
                      ),
                      alignment: AlignmentDirectional.center,
                    ),
                    SizedBox(height: 16.h),

                    // Warning Callout Box
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: const Color(0xFFDC2626),
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: AppText(
                              'تنبيه: سيؤدي هذا الإجراء إلى مسح كافة بياناتك وتقدمك الدراسي في الدورات والواجبات بشكل دائم وفوري، ولا يمكن التراجع عن هذا الإجراء.',
                              style: font12w500.copyWith(
                                color: const Color(0xFF991B1B),
                                height: 1.5,
                              ),
                              maxLines: 10,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Action Buttons Row
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: BounceIt(
                            onPressed: () {
                              if (!isLoading) {
                                context.pop();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
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

                        // Confirm Delete Button
                        Expanded(
                          child: BounceIt(
                            onPressed: () {
                              if (!isLoading) {
                                context
                                    .read<DeleteAccountCubit>()
                                    .deleteAccount();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFDC2626,
                                    ).withValues(alpha: 0.25),
                                    blurRadius: 10.r,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: AppText(
                                'تأكيد الحذف',
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
            ),
          );
        },
      ),
    );
  }
}

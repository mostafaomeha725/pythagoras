import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/features/auth/presentation/cubit/ios_register_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/ios_register_state.dart';

import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';

import 'ios_register_default_layout.dart';
import 'ios_register_tablet_landscape.dart';

class IosRegisterScreenBody extends StatelessWidget {
  const IosRegisterScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IosRegisterCubit, IosRegisterState>(
      listener: (context, state) {
        if (state.status == IosRegisterStatus.loading) {
          showLoading();
        } else if (state.status == IosRegisterStatus.failure) {
          hideLoading();
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            showError(state.errorMessage!);
          }
        } else if (state.status == IosRegisterStatus.success) {
          hideLoading();
          showSuccess(
            state.registerResponse?.message ?? 'تم إنشاء الحساب بنجاح',
          );
          if (context.mounted) {
            context.read<ProfileCubit>().getAccountInfo();
            context.read<CoursesListCubit>().fetchCourses();
          }
          context.go(Routes.mainNavigationScreen);
        }
      },
      builder: (context, state) {
        final mediaSize = MediaQuery.sizeOf(context);
        final isTablet = ResponsiveHelper.isTablet(context);
        final isLandscape = mediaSize.width > mediaSize.height;
        final isTabletLandscape =
            isTablet && isLandscape && mediaSize.width >= 900;

        return LayoutBuilder(
          builder: (context, constraints) {
            return SafeArea(
              child: isTabletLandscape
                  ? IosRegisterTabletLandscape(constraints: constraints)
                  : const IosRegisterDefaultLayout(),
            );
          },
        );
      },
    );
  }
}

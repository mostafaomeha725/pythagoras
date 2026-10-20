import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_state.dart';

import 'login_form.dart';
import 'login_header.dart';
import 'login_register_link.dart';
import 'login_tablet_landscape.dart';

class LoginScreenBody extends StatelessWidget {
  final bool returnBack;
  const LoginScreenBody({super.key, this.returnBack = false});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginLoading) {
          showLoading();
        } else if (state is LoginSuccess) {
          hideLoading();
          if (returnBack) {
            context.pop(true);
          } else {
            context.go(Routes.mainNavigationScreen);
          }
        } else if (state is LoginFailure) {
          showError(state.message);
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
                  ? LoginTabletLandscape(
                      constraints: constraints,
                      returnBack: returnBack,
                    )
                  : _buildDefaultLayout(context),
            );
          },
        );
      },
    );
  }

  Widget _buildDefaultLayout(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 500 : double.infinity,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoginHeader(),

                SizedBox(height: 40.h),

                LoginForm(
                  key: const ValueKey('default_login_form'),
                  onSubmit: (phone, password) {
                    context.read<LoginCubit>().login(phone, password);
                  },
                ),

                SizedBox(height: 24.h),

                const LoginRegisterLink(tabletLandscape: false),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

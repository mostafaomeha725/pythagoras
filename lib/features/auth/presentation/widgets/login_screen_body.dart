import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_state.dart';

import 'login_default_layout.dart';
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
                  : const LoginDefaultLayout(),
            );
          },
        );
      },
    );
  }
}

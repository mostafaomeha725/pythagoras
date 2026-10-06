import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_state.dart';

import 'login_header.dart';
import 'login_form.dart';

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
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LoginHeader(),

                  SizedBox(height: 40.h),

                  LoginForm(
                    onSubmit: (phone, password) {
                      context.read<LoginCubit>().login(phone, password);
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        "ليس لديك حساب؟ ",
                        style: font14w500.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      BounceIt(
                        child: GestureDetector(
                          onTap: () {
                            context.push(Routes.registerScreen);
                          },
                          child: AppText(
                            "إنشاء حساب",
                            style: font14w700.copyWith(
                              color: AppLightColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

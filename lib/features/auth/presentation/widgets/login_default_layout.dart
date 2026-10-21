import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_cubit.dart';

import 'login_form.dart';
import 'login_header.dart';
import 'login_register_link.dart';

class LoginDefaultLayout extends StatelessWidget {
  const LoginDefaultLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Stack(
      children: [
        Padding(
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
                    const LoginHeader(showBackButton: false),

                    SizedBox(height: 36.h),

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
        ),

        // Pinned AppBar Back Button
        PositionedDirectional(
          top: 12.h,
          start: 20.w,
          child: LoginHeader.backButton(
            context,
            size: 38.w,
            iconSize: 18.sp,
            borderRadius: 50.r,
          ),
        ),
      ],
    );
  }
}

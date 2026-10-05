import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_state.dart';

import 'login_header.dart';
import 'password_input.dart';
import 'phone_input.dart';

class LoginScreenBody extends StatefulWidget {
  const LoginScreenBody({super.key});

  @override
  State<LoginScreenBody> createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<LoginScreenBody> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginLoading) {
          showLoading();
        } else if (state is LoginSuccess) {
          hideLoading();
          context.go(Routes.mainNavigationScreen);
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

                  // Phone Label
                  AppText(
                    "رقم الهاتف",
                    style: font14w700.copyWith(color: const Color(0xFF1E1E2D)),
                    alignment: AlignmentDirectional.centerStart,
                  ),
                  SizedBox(height: 8.h),

                  // Phone Input
                  PhoneInput(controller: _phoneController),

                  SizedBox(height: 20.h),

                  // Password Label
                  AppText(
                    "كلمة المرور",
                    style: font14w700.copyWith(color: const Color(0xFF1E1E2D)),
                    alignment: AlignmentDirectional.centerStart,
                    maxLines: 1,
                  ),
                  SizedBox(height: 8.h),

                  // Password Input
                  PasswordInput(controller: _passwordController),

                  // SizedBox(height: 12.h),

                  // // Forgot Password
                  // Align(
                  //   alignment: AlignmentDirectional.centerEnd,
                  //   child: BounceIt(
                  //     child: GestureDetector(
                  //       onTap: () {
                  //         // Navigate to forgot password
                  //       },
                  //       child: AppText(
                  //         "نسيت كلمة المرور؟",
                  //         style: font14w600.copyWith(
                  //           color: AppLightColors.primary,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 40.h),

                  // Login Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: AppButton(
                      text: "تسجيل الدخول",
                      onPressed: () {
                        context.read<LoginCubit>().login(
                          _phoneController.text.trim(),
                          _passwordController.text,
                        );
                      },
                      radius: 16.r,
                      height: 56.h,
                      textColor: Colors.white,
                      textSize: 16.sp,
                      textWeight: FontWeight.bold,
                    ),
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

import 'package:flutter/material.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/constants/app_assets.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/url_launcher_util.dart';
import 'package:pythagoras/core/widgets/app_asset.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/features/auth/presentation/cubit/whatsapp_register_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/whatsapp_register_state.dart';

import 'whatsapp_register_card.dart';

class RegisterScreenBody extends StatelessWidget {
  const RegisterScreenBody({super.key});

  void _openWhatsApp(BuildContext context) {
    context.read<WhatsappRegisterCubit>().getUrl();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WhatsappRegisterCubit, WhatsappRegisterState>(
      listener: (context, state) async {
        if (state is WhatsappRegisterSuccess) {
          final launched =
              await UrlLauncherUtil.openWhatsAppUrl(state.whatsappUrl);
          if (!launched && context.mounted) {
            showError("تعذر فتح واتساب، يرجى التأكد من تثبيت التطبيق.");
          }
        } else if (state is WhatsappRegisterError) {
          showError(state.message);
        }
      },
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 32.h),

              // Logo
              Align(
                alignment: Alignment.center,
                child: AppAsset(assetName: Assets.logoapp, height: 140.h),
              ),

              SizedBox(height: 32.h),

              // Heading
              AppText(
                "إنشاء حساب جديد",
                style: font24w800.copyWith(color: const Color(0xFF1E1E2D)),
                alignment: AlignmentDirectional.center,
              ),

              SizedBox(height: 8.h),

              // Subtitle
              AppText(
                "تواصل معنا عبر واتساب لإكمال تسجيل حسابك بسهولة",
                style: font14w500.copyWith(color: const Color(0xFF6B7280)),
                alignment: AlignmentDirectional.center,
              ),

              SizedBox(height: 40.h),

              // WhatsApp Card
              WhatsAppRegisterCard(onTap: () => _openWhatsApp(context)),
              SizedBox(height: 32.h),
              BlocBuilder<WhatsappRegisterCubit, WhatsappRegisterState>(
                builder: (context, state) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppLightColors.primary.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: AppButton(
                      text: state is WhatsappRegisterLoading
                          ? "جاري التحميل..."
                          : "إنشاء حساب عبر واتساب",
                      onPressed: state is WhatsappRegisterLoading
                          ? null
                          : () => _openWhatsApp(context),
                      radius: 16.r,
                      height: 56.h,
                      textColor: Colors.white,
                      textSize: 16.sp,
                      textWeight: FontWeight.bold,
                    ),
                  );
                },
              ),

              SizedBox(height: 16.h),

              // Secondary Button (Back to Login)
              AppButton(
                text: "العودة إلى تسجيل الدخول",
                onPressed: () {
                  context.go(Routes.loginScreen);
                },
                color: Colors.transparent,
                borderColor: const Color(0xFFE5E7EB),
                textColor: AppLightColors.primary,
                radius: 16.r,
                height: 56.h,
                textSize: 16.sp,
                textWeight: FontWeight.w700,
                elevation: 0,
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

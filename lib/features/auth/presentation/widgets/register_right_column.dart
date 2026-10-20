import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/features/auth/presentation/cubit/whatsapp_register_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/whatsapp_register_state.dart';

import 'whatsapp_register_card.dart';

/// Right Column for Tablet Landscape: WhatsApp card and action buttons.
class RegisterRightColumn extends StatelessWidget {
  final VoidCallback onOpenWhatsApp;

  const RegisterRightColumn({
    super.key,
    required this.onOpenWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // WhatsApp Card with tabletLandscape: true to ensure text doesn't overflow
        WhatsAppRegisterCard(
          onTap: onOpenWhatsApp,
          tabletLandscape: true,
        ),

        const SizedBox(height: 28),

        // Primary Button — إنشاء حساب عبر واتساب
        BlocBuilder<WhatsappRegisterCubit, WhatsappRegisterState>(
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
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
                    ? 'جاري التحميل...'
                    : 'إنشاء حساب عبر واتساب',
                onPressed: state is WhatsappRegisterLoading
                    ? null
                    : onOpenWhatsApp,
                radius: 16,
                height: 56,
                textColor: Colors.white,
                textSize: 16,
                textWeight: FontWeight.bold,
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Secondary Button — العودة إلى تسجيل الدخول
        AppButton(
          text: 'العودة إلى تسجيل الدخول',
          onPressed: () => context.go(Routes.loginScreen),
          color: Colors.transparent,
          borderColor: const Color(0xFFE5E7EB),
          textColor: AppLightColors.primary,
          radius: 16,
          height: 56,
          textSize: 16,
          textWeight: FontWeight.w700,
          elevation: 0,
        ),
      ],
    );
  }
}

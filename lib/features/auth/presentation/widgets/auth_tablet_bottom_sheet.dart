import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/auth/presentation/widgets/auth_tablet_bottom_sheet_actions.dart';

/// Dedicated Tablet Landscape layout for Auth (Login Required) Bottom Sheet.
/// Features a centered, constrained card with proportional typography,
/// overflow-safe scrollable body, and pinned action buttons.
class AuthTabletBottomSheet extends StatelessWidget {
  final VoidCallback? onCancel;
  final Future<void> Function()? onLogin;

  const AuthTabletBottomSheet({
    super.key,
    this.onCancel,
    this.onLogin,
  });

  void _handleCancel(BuildContext context) {
    if (onCancel != null) {
      onCancel!();
    } else {
      context.pop(false);
    }
  }

  Future<void> _handleLogin(BuildContext context) async {
    if (onLogin != null) {
      await onLogin!();
    } else {
      final result = await context.push(
        Routes.loginScreen,
        extra: true,
      );
      if (context.mounted) {
        context.pop(result == true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 450,
          maxHeight: screenHeight * 0.85,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: bottomInset > 0
                ? bottomInset + 12
                : (safeBottom > 0 ? safeBottom + 8 : 18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Scrollable Content to guarantee zero RenderFlex overflow
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lock Icon
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFCEEFA),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_outline_rounded,
                            color: AppLightColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Title
                      AppText(
                        'يجب تسجيل الدخول أولًا',
                        style: font18w700.copyWith(
                          color: const Color(0xFF1E1E2D),
                          fontSize: 17,
                        ),
                        alignment: AlignmentDirectional.center,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),

                      // Subtitle
                      AppText(
                        'لإتمام هذا الإجراء، يُرجى تسجيل الدخول إلى حسابك للاستمرار وتجربة الميزات الكاملة.',
                        style: font14w400.copyWith(
                          color: const Color(0xFF6B7280),
                          height: 1.45,
                          fontSize: 13,
                        ),
                        alignment: AlignmentDirectional.center,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Pinned Action Buttons
              AuthTabletBottomSheetActions(
                onCancel: () => _handleCancel(context),
                onLogin: () => _handleLogin(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

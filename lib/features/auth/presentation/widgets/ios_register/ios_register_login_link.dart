import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class IosRegisterLoginLink extends StatelessWidget {
  final bool tabletLandscape;

  const IosRegisterLoginLink({super.key, this.tabletLandscape = false});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context) || tabletLandscape;
    final textStyle = isTablet
        ? font14w500.copyWith(color: const Color(0xFF6B7280), fontSize: 16)
        : font14w500.copyWith(color: const Color(0xFF6B7280));
    final linkStyle = isTablet
        ? font14w700.copyWith(color: AppLightColors.primary, fontSize: 16)
        : font14w700.copyWith(color: AppLightColors.primary);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            "لديك حساب بالفعل؟ ",
            style: textStyle,
            alignment: AlignmentDirectional.center,
          ),
          BounceIt(
            child: GestureDetector(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(Routes.loginScreen);
                }
              },
              child: AppText(
                "تسجيل الدخول",
                style: linkStyle,
                alignment: AlignmentDirectional.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class LoginRegisterLink extends StatelessWidget {
  final bool tabletLandscape;

  const LoginRegisterLink({super.key, this.tabletLandscape = false});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context) || tabletLandscape;
    final textStyle = isTablet
        ? font14w500.copyWith(color: const Color(0xFF6B7280), fontSize: 16)
        : font14w500.copyWith(color: const Color(0xFF6B7280));
    final linkStyle = isTablet
        ? font14w700.copyWith(color: AppLightColors.primary, fontSize: 16)
        : font14w700.copyWith(color: AppLightColors.primary);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppText(
          "ليس لديك حساب؟ ",
          style: textStyle,
          alignment: AlignmentDirectional.center,
        ),
        BounceIt(
          child: GestureDetector(
            onTap: () {
              context.push(Routes.registerScreen);
            },
            child: AppText(
              "إنشاء حساب",
              style: linkStyle,
              alignment: AlignmentDirectional.center,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_cubit.dart';

import 'login_form.dart';
import 'login_header.dart';
import 'login_register_link.dart';

class LoginTabletLandscape extends StatelessWidget {
  final BoxConstraints constraints;
  final bool returnBack;

  const LoginTabletLandscape({
    super.key,
    required this.constraints,
    this.returnBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = (constraints.maxWidth * 0.045)
        .clamp(24.0, 56.0)
        .toDouble();
    final logoHeight = (constraints.maxHeight * 0.24)
        .clamp(136.0, 168.0)
        .toDouble();

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                // Left Column: Branding centered vertically and horizontally
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: LoginHeader(
                          showBackButton: false,
                          logoHeight: logoHeight,
                          titleStyle: font24w800.copyWith(
                            color: const Color(0xFF1E1E2D),
                            fontSize: 32,
                          ),
                          subtitleStyle: font14w500.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Middle Divider
                Center(
                  child: SizedBox(
                    height: constraints.maxHeight * 0.68,
                    width: 1,
                    child: const ColoredBox(color: Color(0xFFE5E7EB)),
                  ),
                ),

                // Right Column: Login Form & Actions
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, formConstraints) {
                      const verticalPadding = 24.0;
                      final minContentHeight =
                          (formConstraints.maxHeight - verticalPadding * 2)
                              .clamp(0.0, double.infinity)
                              .toDouble();

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          vertical: verticalPadding,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: minContentHeight,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  LoginForm(
                                    key: const ValueKey('tablet_login_form'),
                                    tabletLandscape: true,
                                    onSubmit: (phone, password) {
                                      context.read<LoginCubit>().login(
                                        phone,
                                        password,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 28),
                                  const LoginRegisterLink(
                                    tabletLandscape: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Back button positioned on the RIGHT side
        Positioned(
          top: 16,
          right: horizontalPadding,
          child: LoginHeader.backButton(
            context,
            size: 54,
            iconSize: 24,
            onTap: () {
              if (context.canPop()) {
                context.pop(false);
              } else {
                context.go(Routes.mainNavigationScreen);
              }
            },
          ),
        ),
      ],
    );
  }
}

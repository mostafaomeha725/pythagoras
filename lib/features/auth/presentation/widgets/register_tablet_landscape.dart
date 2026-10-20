import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';

import 'login_header.dart';
import 'register_branding_column.dart';
import 'register_right_column.dart';

/// Tablet Landscape layout for [RegisterScreen].
/// Shown ONLY when width >= 900, height >= 600, and width > height.
/// Mobile Portrait and Tablet Portrait layouts are completely untouched.
class RegisterTabletLandscape extends StatelessWidget {
  final BoxConstraints constraints;
  final VoidCallback onOpenWhatsApp;

  const RegisterTabletLandscape({
    super.key,
    required this.constraints,
    required this.onOpenWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = (constraints.maxWidth * 0.045)
        .clamp(24.0, 56.0)
        .toDouble();
    final logoHeight = (constraints.maxHeight * 0.24)
        .clamp(120.0, 160.0)
        .toDouble();

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  // ─── Left Column: Branding ────────────────────────────────
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: RegisterBrandingColumn(logoHeight: logoHeight),
                      ),
                    ),
                  ),

                  // ─── Vertical Divider ─────────────────────────────────────
                  Center(
                    child: SizedBox(
                      height: constraints.maxHeight * 0.68,
                      width: 1,
                      child: const ColoredBox(color: Color(0xFFE5E7EB)),
                    ),
                  ),

                  // ─── Right Column: WhatsApp Registration ──────────────────
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
                            constraints:
                                BoxConstraints(minHeight: minContentHeight),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 480),
                                child: RegisterRightColumn(
                                  onOpenWhatsApp: onOpenWhatsApp,
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

        // Back button positioned on the top-right
        Positioned(
          top: 16,
          right: horizontalPadding,
          child: LoginHeader.backButton(
            context,
            size: 54,
            iconSize: 24,
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(Routes.loginScreen);
              }
            },
          ),
        ),
      ],
    );
  }
}


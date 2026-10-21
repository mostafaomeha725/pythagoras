import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/styles.dart';

import 'ios_register_form.dart';
import 'ios_register_header.dart';
import 'ios_register_login_link.dart';

class IosRegisterTabletLandscape extends StatelessWidget {
  final BoxConstraints constraints;

  const IosRegisterTabletLandscape({super.key, required this.constraints});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = (constraints.maxWidth * 0.045)
        .clamp(24.0, 56.0)
        .toDouble();
    final logoHeight = (constraints.maxHeight * 0.22)
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
                // Left Column: Branding
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: IosRegisterHeader(
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
                    height: constraints.maxHeight * 0.72,
                    width: 1,
                    child: const ColoredBox(color: Color(0xFFE5E7EB)),
                  ),
                ),

                // Right Column: Form
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
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  IosRegisterForm(
                                    key: ValueKey('tablet_ios_register_form'),
                                    tabletLandscape: true,
                                  ),
                                  SizedBox(height: 24),
                                  IosRegisterLoginLink(tabletLandscape: true),
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

        // Back button on top right
        Positioned(
          top: 16,
          right: horizontalPadding,
          child: IosRegisterHeader.backButton(
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

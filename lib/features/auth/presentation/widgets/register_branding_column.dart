import 'package:flutter/material.dart';
import 'package:pythagoras/core/constants/app_assets.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_asset.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Left Column for Tablet Landscape: App Logo, Title, and Subtitle.
class RegisterBrandingColumn extends StatelessWidget {
  final double logoHeight;

  const RegisterBrandingColumn({
    super.key,
    required this.logoHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAsset(
          assetName: Assets.logoapp,
          height: logoHeight,
        ),
        const SizedBox(height: 24),
        AppText(
          'إنشاء حساب جديد',
          style: font24w800.copyWith(
            color: const Color(0xFF1E1E2D),
            fontSize: 28,
          ),
          alignment: AlignmentDirectional.center,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.visible,
        ),
        const SizedBox(height: 10),
        AppText(
          'تواصل معنا عبر واتساب لإكمال تسجيل حسابك بسهولة',
          style: font14w500.copyWith(
            color: const Color(0xFF6B7280),
            fontSize: 16,
          ),
          alignment: AlignmentDirectional.center,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }
}

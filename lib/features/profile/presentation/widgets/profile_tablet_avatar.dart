import 'package:flutter/material.dart';
import 'package:pythagoras/core/constants/app_assets.dart';
import 'package:pythagoras/core/widgets/app_asset.dart';

/// Student Avatar Circle with Primary Border Ring and Shadow for Tablet.
class ProfileTabletAvatar extends StatelessWidget {
  final String? profilePictureUrl;

  const ProfileTabletAvatar({super.key, this.profilePictureUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF832561), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14832561),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        width: 84,
        height: 84,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: const AppAsset(
              assetName: Assets.logoapp,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

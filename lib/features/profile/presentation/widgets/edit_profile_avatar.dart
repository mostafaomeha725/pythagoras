import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';

class EditProfileAvatar extends StatelessWidget {
  final String? profilePictureUrl;

  const EditProfileAvatar({super.key, this.profilePictureUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 110.w,
        height: 110.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppLightColors.primary, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppLightColors.primary.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Image.asset('assets/logoapp.jpeg', fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

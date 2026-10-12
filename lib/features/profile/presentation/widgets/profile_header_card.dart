import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String grade;
  final String? profilePictureUrl;

  const ProfileHeaderCard({
    super.key, 
    required this.name, 
    required this.grade,
    this.profilePictureUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0x05000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF832561), width: 2.5.w),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x12832561),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Image.asset(
                    'assets/logoapp.jpeg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Name
          AppText(
            name,
            style: font20w700.copyWith(color: const Color(0xFF1E1E2D)),
            alignment: AlignmentDirectional.center,
          ),

          SizedBox(height: 8.h),

          // Grade
          AppText(
            grade,
            style: font14w500.copyWith(color: const Color(0xFF6B7280)),
            alignment: AlignmentDirectional.center,
          ),
        ],
      ),
    );
  }
}

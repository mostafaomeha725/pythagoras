import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
            ),
            child: Container(
              width: 72.w,
              height: 72.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFDF4FA),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: profilePictureUrl != null && profilePictureUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: profilePictureUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Center(
                          child: Text('🧑‍🎓', style: TextStyle(fontSize: 40.sp)),
                        ),
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(color: const Color(0xFF832561), strokeWidth: 2.w),
                        ),
                      )
                    : Center(
                        child: Text('🧑‍🎓', style: TextStyle(fontSize: 40.sp)),
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

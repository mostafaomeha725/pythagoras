import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';
import 'package:pythagoras/features/profile/presentation/widgets/profile_tablet_avatar.dart';

/// Right-hand sidebar card for Edit Profile screen in Tablet Landscape.
/// Shows current student identity, role, and helpful guidance notes.
class EditProfileTabletSidebar extends StatelessWidget {
  final UserProfile? userProfile;

  const EditProfileTabletSidebar({super.key, this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Student Avatar
          ProfileTabletAvatar(
            profilePictureUrl: userProfile?.profilePictureUrl,
          ),
          const SizedBox(height: 14),

          // Current Name
          AppText(
            userProfile?.name ?? 'طالب فيثاغورس',
            style: font20w700.copyWith(
              color: const Color(0xFF1E1E2D),
              fontSize: 18.5,
            ),
            alignment: AlignmentDirectional.center,
          ),
          const SizedBox(height: 6),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDCFCE7), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.school_outlined,
                  size: 15,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 6),
                AppText(
                  userProfile?.role ?? 'طالب مسجل',
                  style: font14w600.copyWith(
                    color: const Color(0xFF15803D),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),

          // Security & Guidance Note Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 18,
                      color: Color(0xFF832561),
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      "إرشادات التعديل",
                      style: font14w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppText(
                  "يمكنك تحديث اسمك وتعيين كلمة مرور جديدة في أي وقت. رقم الهاتف ونوع الحساب مرتبطان بهويتك التعليمية لحماية حسابك.",
                  style: font12w500.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

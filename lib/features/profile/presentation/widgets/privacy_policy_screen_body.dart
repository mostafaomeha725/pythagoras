import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_contact_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_header_banner.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_section_card.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_sections_data.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_web_card.dart';

class PrivacyPolicyScreenBody extends StatelessWidget {
  const PrivacyPolicyScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      physics: const BouncingScrollPhysics(),
      children: [
        const PrivacyPolicyHeaderBanner(),
        SizedBox(height: 16.h),
        const PrivacyPolicyWebCard(),
        SizedBox(height: 4.h),
        ...PrivacyPolicySectionsData.sections.map(
          (section) => PrivacyPolicySectionCard(
            title: section.title,
            icon: section.icon,
            points: section.points,
            note: section.note,
          ),
        ),
        const PrivacyPolicyContactCard(),
      ],
    );
  }
}

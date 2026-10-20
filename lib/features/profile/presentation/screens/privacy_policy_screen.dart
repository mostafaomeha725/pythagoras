import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/constants/strings.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/utils/url_launcher_helper.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_app_bar.dart';
import 'package:pythagoras/features/profile/presentation/widgets/privacy_policy_screen_body.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet =
            ResponsiveHelper.isTablet(context) ||
            (constraints.maxWidth >= 900 &&
                constraints.maxWidth > constraints.maxHeight);

        return Scaffold(
          appBar: isTablet
              ? null
              : CourseDetailAppBar(
                  title: 'سياسة الخصوصية',
                  action: BounceIt(
                    onPressed: () => UrlLauncherHelper.openUrl(
                      AppStrings.privacyPolicyWebUrl,
                    ),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppLightColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.language_rounded,
                          color: AppLightColors.primary,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ),
          body: const SafeArea(child: PrivacyPolicyScreenBody()),
        );
      },
    );
  }
}

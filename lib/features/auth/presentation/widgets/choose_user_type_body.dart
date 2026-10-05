import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/constants/app_assets.dart';
import 'package:pythagoras/core/widgets/app_asset.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

import 'user_type_option_card.dart';

class ChooseUserTypeBody extends StatefulWidget {
  const ChooseUserTypeBody({super.key});

  @override
  State<ChooseUserTypeBody> createState() => _ChooseUserTypeBodyState();
}

class _ChooseUserTypeBodyState extends State<ChooseUserTypeBody> {
  int selectedIndex = 0; // 0 for Student, 1 for Parent

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),

            // Top Right Back Button
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: BounceIt(
                child: InkWell(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
                  borderRadius: BorderRadius.circular(50.r),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCEEFA),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppLightColors.primary,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Logo
            Align(
              alignment: Alignment.center,
              child: AppAsset(
                assetName: Assets.logo,
                height: 85.h,
              ),
            ),

            SizedBox(height: 32.h),

            // Heading
            AppText(
              "أنت تستخدم Eelu ك؟",
              style: font24w800.copyWith(
                color: const Color(0xFF1E1E2D),
              ),
              alignment: AlignmentDirectional.center,
            ),

            SizedBox(height: 8.h),

            // Subtitle
            AppText(
              "اختر نوع الحساب لتخصيص تجربتك التعليمية",
              style: font14w500.copyWith(
                color: const Color(0xFF6B7280),
              ),
              alignment: AlignmentDirectional.center,
            ),

            SizedBox(height: 32.h),

            // Student Card
            UserTypeOptionCard(
              title: "طالب",
              subtitle:
                  "أريد التعلم والاستمتاع بالدروس وحل الاختبارات التفاعلية",
              icon: Icons.school_outlined,
              isSelected: selectedIndex == 0,
              onTap: () => setState(() => selectedIndex = 0),
            ),

            SizedBox(height: 16.h),

            // Parent Card
            UserTypeOptionCard(
              title: "ولي أمر",
              subtitle: "أريد متابعة تقدم أبنائي الدراسي والاطلاع على التقارير",
              icon: Icons.person_outline,
              isSelected: selectedIndex == 1,
              onTap: () => setState(() => selectedIndex = 1),
            ),

            const Spacer(),

            // Continue Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppLightColors.primary.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: AppButton(
                text: "متابعة",
                onPressed: () {
                  context.push(Routes.registerScreen);
                },
                radius: 16.r,
                height: 56.h,
                textColor: Colors.white,
                textSize: 16.sp,
                textWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

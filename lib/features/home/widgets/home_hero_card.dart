import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class HomeHeroCard extends StatelessWidget {
  final VoidCallback onStartLearning;

  const HomeHeroCard({super.key, required this.onStartLearning});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppLightColors.primary,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppLightColors.primary.withValues(alpha: 0.3),
            blurRadius: 20.r,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "منصتك الأفضل لتعلم الرياضيات بثقة وإتقان",
                      style: font18w700.copyWith(
                        color: Colors.white,
                        height: 1.4,
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 8.h),
                    AppText(
                      "ابدأ رحلتك في عالم الأرقام والمعادلات مع دورات عملية وتحديات تفاعلية",
                      style: font13w600.copyWith(
                        color: Color(0xffE9D5FF),
                        height: 1.5,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              // Icon
              // Container(
              //   width: 60.w,
              //   height: 60.w,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(16.r),
              //   ),
              //   child: Center(
              //     child: Text("📐", style: TextStyle(fontSize: 32.sp)),
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 24.h),
          // Start Button
          BounceIt(
            onPressed: onStartLearning,
            child: Container(
              width: double.infinity,
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: AppText(
                  "ابدأ التعلم الآن",
                  style: font14w700.copyWith(color: Color(0xff4C1D95)),
                  alignment: AlignmentDirectional.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

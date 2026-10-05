import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/online_lesson.dart';
import 'package:pythagoras/core/utils/url_launcher_util.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class OnlineLessonCardActions extends StatelessWidget {
  final OnlineLesson lesson;

  const OnlineLessonCardActions({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Platform Info
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EEF5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.videocam_outlined,
                color: AppLightColors.primary,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 8.w),
            AppText(
              'يفتح عبر ${lesson.platform}',
              style: font12w500.copyWith(color: const Color(0xFF9CA3AF)),
            ),
          ],
        ),
        // Join Button
        BounceIt(
          onPressed: () async {
            if (lesson.joinUrl.isNotEmpty) {
              EasyLoading.show(status: 'جاري التحضير...');
              try {
                await UrlLauncherUtil.launchAnyUrl(lesson.joinUrl);
                EasyLoading.dismiss();
              } catch (e) {
                EasyLoading.dismiss();
                showError('تعذر فتح الرابط');
              }
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppLightColors.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  'انضم للحصة',
                  style: font14w700.copyWith(color: Colors.white),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.open_in_new_rounded, color: Colors.white, size: 18.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

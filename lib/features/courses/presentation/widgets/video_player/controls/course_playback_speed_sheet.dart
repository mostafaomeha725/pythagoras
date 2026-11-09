import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import '../adapters/course_video_adapter.dart';

class CoursePlaybackSpeedSheet extends StatelessWidget {
  final CourseVideoAdapter adapter;

  static const List<double> availableSpeeds = [
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  const CoursePlaybackSpeedSheet({super.key, required this.adapter});

  static Future<void> show(BuildContext context, CourseVideoAdapter adapter) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => CoursePlaybackSpeedSheet(adapter: adapter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSpeed = adapter.playbackSpeed;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            AppText(
              'سرعة التشغيل',
              style: font16w700.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
              alignment: AlignmentDirectional.center,
            ),
            SizedBox(height: 12.h),
            ...availableSpeeds.map((speed) {
              final isSelected = (speed - currentSpeed).abs() < 0.05;
              final label = speed == 1.0 ? '1.0x (عادي)' : '${speed}x';

              return InkWell(
                onTap: () {
                  adapter.setPlaybackSpeed(speed);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(10.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        label,
                        style: font14w500.copyWith(
                          color: isSelected
                              ? AppLightColors.secondary
                              : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_rounded,
                          color: AppLightColors.secondary,
                          size: 20.w,
                        ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

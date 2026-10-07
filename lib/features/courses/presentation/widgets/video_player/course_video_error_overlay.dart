import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class CourseVideoErrorOverlay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const CourseVideoErrorOverlay({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          height: 220.h,
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.videocam_off_rounded,
                  color: Colors.white,
                  size: 32.w,
                ),
              ),
              SizedBox(height: 12.h),
              AppText(
                errorMessage.isNotEmpty ? errorMessage : 'الفيديو غير متاح',
                style: font16w700.copyWith(color: Colors.white),
                alignment: AlignmentDirectional.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

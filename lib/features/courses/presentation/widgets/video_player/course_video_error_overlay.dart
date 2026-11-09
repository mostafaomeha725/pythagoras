import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
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
    final isNetworkError = errorMessage.contains('الإنترنت');
    final isTablet = ResponsiveHelper.isTablet(context);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNetworkError
                      ? Icons.wifi_off_rounded
                      : Icons.videocam_off_rounded,
                  color: Colors.redAccent,
                  size: 28.w,
                ),
              ),
              SizedBox(height: 12.h),
              AppText(
                errorMessage,
                style: font16w700.copyWith(
                  color: Colors.white,
                  fontSize: isTablet ? 14 : 16.sp,
                  height: 1.3,
                ),
                alignment: AlignmentDirectional.center,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              SizedBox(height: isTablet ? 16.h : 20.h),
              SizedBox(
                width: isTablet ? 190 : 180.w,
                height: 44,
                child: TextButton.icon(
                  onPressed: onRetry,
                  icon: Icon(Icons.refresh_rounded, size: isTablet ? 18 : 20.w),
                  label: Text(
                    'إعادة المحاولة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: font14w700.copyWith(
                      color: Colors.white,
                      fontSize: isTablet ? 14 : 14.sp,
                      height: 1.1,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

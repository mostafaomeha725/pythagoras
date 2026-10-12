import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class NoInternetWidget extends StatelessWidget {
  final String? message;
  final String? title;
  final String? subTitle;
  final VoidCallback? onRetry;
  final String? retryText;

  const NoInternetWidget({
    super.key,
    this.message,
    this.title,
    this.subTitle,
    this.onRetry,
    this.retryText,
  });

  bool get _isConnectionIssue {
    final msg = message ?? '';
    if (msg.isEmpty) return true;
    final lower = msg.toLowerCase();
    return msg.contains('إنترنت') ||
        msg.contains('اتصال') ||
        lower.contains('internet') ||
        lower.contains('connection') ||
        lower.contains('socket') ||
        lower.contains('network');
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = _isConnectionIssue;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dual-layer elevated badge
            Container(
              width: 92.w,
              height: 92.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 68.w,
                  height: 68.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isOffline
                        ? Icons.wifi_off_rounded
                        : Icons.error_outline_rounded,
                    size: 32.sp,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            AppText(
              title ??
                  (isOffline
                      ? 'لا يوجد اتصال بالإنترنت'
                      : 'عذراً، حدث خطأ ما!'),
              style: font18w700.copyWith(color: const Color(0xFF1E1E2D)),
              textAlign: TextAlign.center,
              alignment: AlignmentDirectional.center,
            ),
            SizedBox(height: 10.h),
            AppText(
              subTitle ??
                  (isOffline
                      ? 'يرجى التحقق من اتصالك بشبكة الواي فاي أو بيانات الهاتف ثم المحاولة مرة أخرى.'
                      : (message ??
                            'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً.')),
              style: font14w500.copyWith(
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              alignment: AlignmentDirectional.center,
              maxLines: 4,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 28.h),
              SizedBox(
                width: 200.w,
                child: AppButton(
                  text: retryText ?? 'إعادة المحاولة',
                  onPressed: onRetry,
                  height: 48.h,
                  radius: 14.r,
                  color: AppLightColors.primary,
                  textColor: Colors.white,
                  textSize: 15.sp,
                  textWeight: FontWeight.w700,
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

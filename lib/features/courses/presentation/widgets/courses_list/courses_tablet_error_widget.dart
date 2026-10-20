import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Professional, perfectly proportioned Error & No-Internet state for Tablet Landscape.
/// Avoids massive ScreenUtil inflation and fits within the tablet viewport with 0 clipping.
class CoursesTabletErrorWidget extends StatelessWidget {
  final String? message;
  final String? title;
  final String? subTitle;
  final VoidCallback? onRetry;
  final String? retryText;

  const CoursesTabletErrorWidget({
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dual-layer elevated badge
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    isOffline
                        ? Icons.wifi_off_rounded
                        : Icons.error_outline_rounded,
                    size: 28,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppText(
              title ??
                  (isOffline
                      ? 'لا يوجد اتصال بالإنترنت'
                      : 'عذراً، حدث خطأ ما!'),
              style: font18w700.copyWith(
                color: const Color(0xFF1E1E2D),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
              alignment: AlignmentDirectional.center,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: AppText(
                subTitle ??
                    (isOffline
                        ? 'يرجى التحقق من اتصالك بشبكة الواي فاي أو بيانات الهاتف ثم المحاولة مرة أخرى.'
                        : (message ??
                              'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً.')),
                style: font14w500.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 13.5,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
                alignment: AlignmentDirectional.center,
                maxLines: 3,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 22),
              SizedBox(
                width: 190,
                child: AppButton(
                  text: retryText ?? 'إعادة المحاولة',
                  onPressed: onRetry,
                  height: 44,
                  radius: 12,
                  color: AppLightColors.primary,
                  textColor: Colors.white,
                  textSize: 14.5,
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

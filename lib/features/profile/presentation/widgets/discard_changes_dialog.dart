import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class DiscardChangesDialog extends StatelessWidget {
  const DiscardChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: Colors.red,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            AppText(
              'تجاهل التعديلات؟',
              style: font18w700.copyWith(color: const Color(0xFF1E1E2D)),
              alignment: AlignmentDirectional.center,
            ),
            SizedBox(height: 12.h),

            // Subtitle
            AppText(
              'لديك تعديلات غير محفوظة. الرجوع الآن سيؤدي إلى فقدان جميع التغييرات التي قمت بها.',
              style: font14w400.copyWith(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              alignment: AlignmentDirectional.center,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            SizedBox(height: 32.h),

            // Actions
            Row(
              children: [
                Expanded(
                  child: BounceIt(
                    onPressed: () => Navigator.pop(context, false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: AppText(
                        'تراجع',
                        style: font14w600.copyWith(
                          color: const Color(0xFF1E1E2D),
                        ),
                        alignment: AlignmentDirectional.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: BounceIt(
                    onPressed: () => Navigator.pop(context, true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: AppText(
                        'تجاهل',
                        style: font14w600.copyWith(color: Colors.white),
                        alignment: AlignmentDirectional.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

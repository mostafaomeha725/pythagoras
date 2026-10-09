import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class QuizActionButtons extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isSubmitting;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;

  const QuizActionButtons({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.isSubmitting,
    required this.onNext,
    required this.onPrevious,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFF3F4F6), width: 1.h),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : (isLast ? onSubmit : onNext),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF832561),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : AppText(
                      isLast ? 'إنهاء' : 'التالي',
                      style: font16w700.copyWith(color: Colors.white),
                      alignment: AlignmentDirectional.center,
                    ),
            ),
          ),
          if (!isFirst) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: OutlinedButton(
                onPressed: isSubmitting ? null : onPrevious,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppLightColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: AppText(
                  'السابق',
                  style: font16w700.copyWith(color: AppLightColors.primary),
                  alignment: AlignmentDirectional.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

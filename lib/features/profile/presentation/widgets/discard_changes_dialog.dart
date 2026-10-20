import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:go_router/go_router.dart';

class DiscardChangesDialog extends StatelessWidget {
  const DiscardChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = MediaQuery.sizeOf(context).width >= 600;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 20 : 24.r),
          ),
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 40 : 24.w,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 420 : double.infinity,
            ),
            child: Padding(
              padding: isTablet
                  ? const EdgeInsets.symmetric(horizontal: 24, vertical: 24)
                  : EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: isTablet
                        ? const EdgeInsets.all(14)
                        : EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: Colors.red,
                      size: isTablet ? 30 : 32.sp,
                    ),
                  ),
                  SizedBox(height: isTablet ? 16 : 20.h),

                  // Title
                  AppText(
                    'تجاهل التعديلات؟',
                    style: isTablet
                        ? font18w700.copyWith(
                            color: const Color(0xFF1E1E2D),
                            fontSize: 18,
                          )
                        : font18w700.copyWith(color: const Color(0xFF1E1E2D)),
                    alignment: AlignmentDirectional.center,
                  ),
                  SizedBox(height: isTablet ? 10 : 12.h),

                  // Subtitle
                  AppText(
                    'لديك تعديلات غير محفوظة. الرجوع الآن سيؤدي إلى فقدان جميع التغييرات التي قمت بها.',
                    style: isTablet
                        ? font14w400.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 13.5,
                            height: 1.5,
                          )
                        : font14w400.copyWith(
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                    alignment: AlignmentDirectional.center,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                  SizedBox(height: isTablet ? 24 : 32.h),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: BounceIt(
                          onPressed: () => context.pop(false),
                          child: Container(
                            height: isTablet ? 46 : null,
                            padding: isTablet
                                ? const EdgeInsets.symmetric(vertical: 12)
                                : EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(
                                isTablet ? 12 : 12.r,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: AppText(
                              'تراجع',
                              style: font14w600.copyWith(
                                color: const Color(0xFF1E1E2D),
                                fontSize: isTablet ? 14 : null,
                              ),
                              alignment: AlignmentDirectional.center,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isTablet ? 12 : 16.w),
                      Expanded(
                        child: BounceIt(
                          onPressed: () => context.pop(true),
                          child: Container(
                            height: isTablet ? 46 : null,
                            padding: isTablet
                                ? const EdgeInsets.symmetric(vertical: 12)
                                : EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(
                                isTablet ? 12 : 12.r,
                              ),
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
                              style: font14w600.copyWith(
                                color: Colors.white,
                                fontSize: isTablet ? 14 : null,
                              ),
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
          ),
        );
      },
    );
  }
}

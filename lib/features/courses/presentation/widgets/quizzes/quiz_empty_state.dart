import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Empty state shown inside QuizScreenBody or QuizTabletLandscape when the quiz has no questions.
class QuizEmptyState extends StatelessWidget {
  const QuizEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isTablet(context)) {
      return _buildTabletEmptyState(context);
    }
    return _buildMobileEmptyState(context);
  }

  Widget _buildTabletEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.quiz_outlined,
                    color: Color(0xFFD1D5DB),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                AppText(
                  'لا توجد أسئلة',
                  style: font16w700.copyWith(
                    color: const Color(0xFF374151),
                    fontSize: 16,
                  ),
                  alignment: AlignmentDirectional.center,
                ),
                const SizedBox(height: 8),
                AppText(
                  'هذا الامتحان لا يحتوي على أي أسئلة حالياً',
                  style: font12w500.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  alignment: AlignmentDirectional.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.quiz_outlined,
                  color: const Color(0xFFD1D5DB),
                  size: 36.w,
                ),
              ),
              SizedBox(height: 20.h),
              AppText(
                'لا توجد أسئلة',
                style: font16w700.copyWith(color: const Color(0xFF374151)),
                alignment: AlignmentDirectional.center,
              ),
              SizedBox(height: 8.h),
              AppText(
                'هذا الامتحان لا يحتوي على أي أسئلة حالياً',
                style: font12w500.copyWith(color: const Color(0xFF9CA3AF)),
                textAlign: TextAlign.center,
                alignment: AlignmentDirectional.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

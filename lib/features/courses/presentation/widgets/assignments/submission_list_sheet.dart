import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/cubit/submit_assignment/submit_assignment_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/submit_assignment/submit_assignment_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submission_item.dart';

class SubmissionListSheet extends StatelessWidget {
  final int assignmentId;
  final String assignmentTitle;

  const SubmissionListSheet({
    super.key,
    required this.assignmentId,
    required this.assignmentTitle,
  });

  static Future<void> show(
    BuildContext context, {
    required int assignmentId,
    required String assignmentTitle,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => sl<SubmitAssignmentCubit>()..fetchSubmissions(assignmentId),
        child: SubmissionListSheet(
          assignmentId: assignmentId,
          assignmentTitle: assignmentTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          AppText(
            'تسليماتي',
            style: font20w700.copyWith(color: const Color(0xFF1E1E2D)),
          ),
          SizedBox(height: 4.h),
          AppText(
            assignmentTitle,
            style: font13w500.copyWith(color: const Color(0xFF6B7280)),
          ),
          SizedBox(height: 20.h),

          Flexible(
            child: BlocBuilder<SubmitAssignmentCubit, SubmitAssignmentState>(
              builder: (context, state) {
                if (state is SubmissionsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SubmissionsError) {
                  return Center(
                    child: AppText(
                      state.message,
                      style: font14w500.copyWith(color: const Color(0xFF6B7280)),
                    ),
                  );
                }
                if (state is SubmissionsLoaded) {
                  if (state.submissions.isEmpty) {
                    return Center(
                      child: AppText(
                        'لا توجد تسليمات بعد',
                        style: font14w500.copyWith(color: const Color(0xFF9CA3AF)),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: state.submissions.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (_, i) => SubmissionItem(submission: state.submissions[i]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/cubit/submit_assignment/submit_assignment_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/submit_assignment/submit_assignment_state.dart';

class SubmitAssignmentHeader extends StatelessWidget {
  final String assignmentTitle;
  final VoidCallback onMySubmissions;

  const SubmitAssignmentHeader({
    super.key,
    required this.assignmentTitle,
    required this.onMySubmissions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AppText(
            'تسليم: $assignmentTitle',
            style: font18w700.copyWith(color: const Color(0xFF1E1E2D)),
            maxLines: 2,
          ),
        ),
        BounceIt(
          onPressed: onMySubmissions,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF6EEF5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: AppText(
              'تسليماتي',
              style: font12w700.copyWith(color: const Color(0xFF832561)),
            ),
          ),
        ),
      ],
    );
  }
}

class SubmitAssignmentButton extends StatelessWidget {
  final VoidCallback onSubmit;

  const SubmitAssignmentButton({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubmitAssignmentCubit, SubmitAssignmentState>(
      builder: (context, state) {
        return AppButton(
          text: 'تسليم الواجب',
          onPressed: onSubmit,
        );
      },
    );
  }
}

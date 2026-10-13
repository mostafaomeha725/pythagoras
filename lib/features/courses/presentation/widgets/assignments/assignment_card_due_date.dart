import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/date_formatter.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class AssignmentCardDueDate extends StatelessWidget {
  final String dueDate;

  const AssignmentCardDueDate({super.key, required this.dueDate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 14.sp,
          color: const Color(0xFF9CA3AF),
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: AppText(
            ' التسليم قبل: ${DateFormatter.formatYMDWithTime(dueDate)}',
            style: font12w500.copyWith(color: const Color(0xFF6B7280)),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

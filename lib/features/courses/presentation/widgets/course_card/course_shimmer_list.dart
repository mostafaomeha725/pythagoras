import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_card/course_shimmer_card.dart';

class CourseShimmerList extends StatelessWidget {
  final int count;
  final bool isHorizontal;

  const CourseShimmerList({
    super.key,
    this.count = 4,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return SizedBox(
        height: 260.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: count,
          separatorBuilder: (context, index) => SizedBox(width: 16.w),
          itemBuilder: (context, index) => SizedBox(
            width: 240.w,
            child: const CourseShimmerCard(),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) => const CourseShimmerCard(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_image.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_info.dart';

class CourseDetailHeader extends StatelessWidget {
  final CourseDetail course;

  const CourseDetailHeader({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video / Thumbnail
        CourseDetailImage(course: course),
        SizedBox(height: 20.h),
        
        // Title, Meta, Price, Description
        CourseDetailInfo(course: course),
      ],
    );
  }
}

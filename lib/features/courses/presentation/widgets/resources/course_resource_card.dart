import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_resource_card_action.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_resource_card_header.dart';

class CourseResourceCard extends StatelessWidget {
  final CourseResource resource;

  const CourseResourceCard({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0x05000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CourseResourceCardHeader(resource: resource),
          SizedBox(height: 24.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CourseResourceCardAction(resource: resource),
          ),
        ],
      ),
    );
  }
}


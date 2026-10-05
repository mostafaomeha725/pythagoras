import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/widgets/app_image.dart';

class CourseVideoFallback extends StatelessWidget {
  final String imageUrl;

  const CourseVideoFallback({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: AppImage(
        imageUrl: imageUrl,
        height: 220.h,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

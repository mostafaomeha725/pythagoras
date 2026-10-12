import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_resource_card_file_badge.dart';

class CourseResourceCardHeader extends StatelessWidget {
  final CourseResource resource;

  const CourseResourceCardHeader({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CourseResourceCardFileBadge(fileExt: resource.fileExtension),
        // Title and Subtitle (Leftmost in RTL)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                resource.title,
                style: font16w700.copyWith(color: const Color(0xFF1E1E2D)),
                maxLines: 2,
              ),
              SizedBox(height: 8.h),
              if (resource.description.isNotEmpty) ...[
                AppText(
                  resource.description,
                  style: font12w500.copyWith(color: const Color(0xFF6B7280)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

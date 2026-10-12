import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// File badge displayed on [CourseResourceCard], matching the visual styling
/// and color scheme of assignment cards in the exams/assignments section.
class CourseResourceCardFileBadge extends StatelessWidget {
  final String fileExt;

  const CourseResourceCardFileBadge({super.key, required this.fileExt});

  @override
  Widget build(BuildContext context) {
    Color bgColor = const Color(0xFFFEF2F2);
    Color fgColor = const Color(0xFFEF4444);
    IconData icon = Icons.picture_as_pdf_outlined;

    final ext = fileExt.toUpperCase();
    if (ext.contains('DOC') || ext.contains('DOCX') || ext.contains('WORD')) {
      bgColor = const Color(0xFFEFF6FF);
      fgColor = const Color(0xFF3B82F6);
      icon = Icons.description_outlined;
    } else if (ext.contains('PDF')) {
      bgColor = const Color(0xFFFEF2F2);
      fgColor = const Color(0xFFEF4444);
      icon = Icons.picture_as_pdf_outlined;
    } else if (ext.contains('JPG') ||
        ext.contains('PNG') ||
        ext.contains('JPEG')) {
      bgColor = const Color(0xFFF0FDF4);
      fgColor = const Color(0xFF22C55E);
      icon = Icons.image_outlined;
    } else if (ext.contains('PPT') || ext.contains('PPTX')) {
      bgColor = const Color(0xFFFFF7ED);
      fgColor = const Color(0xFFF97316);
      icon = Icons.slideshow_outlined;
    } else if (ext.contains('XLS') ||
        ext.contains('XLSX') ||
        ext.contains('EXCEL')) {
      bgColor = const Color(0xFFECFDF5);
      fgColor = const Color(0xFF10B981);
      icon = Icons.table_chart_outlined;
    } else {
      bgColor = const Color(0xFFF3F4F6);
      fgColor = const Color(0xFF6B7280);
      icon = Icons.insert_drive_file_outlined;
    }

    return Container(
      margin: EdgeInsets.only(left: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fgColor, size: 26.sp),
          SizedBox(height: 6.h),
          AppText(ext, style: font12w700.copyWith(color: fgColor)),
        ],
      ),
    );
  }
}

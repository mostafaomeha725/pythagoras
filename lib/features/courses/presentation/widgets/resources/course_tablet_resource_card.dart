import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_tablet_resource_card_action.dart';

/// Resource card component optimized for Tablet Landscape.
/// Uses explicit typography and paddings without ScreenUtil scaling.
class CourseTabletResourceCard extends StatelessWidget {
  final CourseResource resource;

  const CourseTabletResourceCard({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    Color bgColor = const Color(0xFFFEF2F2);
    Color fgColor = const Color(0xFFEF4444);
    IconData icon = Icons.picture_as_pdf_outlined;

    final ext = resource.fileExtension.toUpperCase();
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File Badge (Right in RTL)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: fgColor, size: 22),
                    const SizedBox(height: 4),
                    AppText(
                      ext,
                      style: font12w700.copyWith(color: fgColor, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      resource.title,
                      style: font16w700.copyWith(
                        color: const Color(0xFF1E1E2D),
                        fontSize: 15,
                      ),
                      maxLines: 2,
                    ),
                    if (resource.description.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      AppText(
                        resource.description,
                        style: font12w500.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CourseTabletResourceCardAction(resource: resource),
          ),
        ],
      ),
    );
  }
}

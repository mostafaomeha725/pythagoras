import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_source_mobile_sheet.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_source_tablet_option.dart';

/// Modal bottom sheet to choose file source (Photos or Documents).
class SubmitAssignmentSourceSheet extends StatelessWidget {
  final VoidCallback onPickGallery;
  final VoidCallback onPickFileSystem;

  const SubmitAssignmentSourceSheet({
    super.key,
    required this.onPickGallery,
    required this.onPickFileSystem,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onPickGallery,
    required VoidCallback onPickFileSystem,
  }) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final content = SubmitAssignmentSourceSheet(
          onPickGallery: onPickGallery,
          onPickFileSystem: onPickFileSystem,
        );

        if (isTablet) {
          return SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: content,
              ),
            ),
          );
        }
        return content;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    if (isTablet) {
      return _buildTabletContent(context);
    }
    return SubmitAssignmentSourceMobileSheet(
      onPickGallery: onPickGallery,
      onPickFileSystem: onPickFileSystem,
    );
  }

  Widget _buildTabletContent(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              AppText(
                'اختر طريقة الرفع',
                style: font16w700.copyWith(
                  color: const Color(0xFF1E1E2D),
                  fontSize: 17,
                ),
                alignment: AlignmentDirectional.center,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Option 1: Gallery
              SubmitAssignmentSourceTabletOption(
                icon: Icons.photo_library_outlined,
                title: 'معرض الصور (Photos)',
                subtitle: 'اختيار صورة من ألبوم الصور مباشرة',
                onTap: onPickGallery,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF3F4F6),
                ),
              ),

              // Option 2: Files / Documents
              SubmitAssignmentSourceTabletOption(
                icon: Icons.folder_open_outlined,
                title: 'الملفات والمستندات (Files)',
                subtitle: 'تصفح المستندات و iCloud Drive وملفات الجهاز',
                onTap: onPickFileSystem,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Preview card for an attached file in Tablet Landscape homework submission.
class SubmitAssignmentTabletPickedFilePreview extends StatelessWidget {
  final PlatformFile pickedFile;
  final VoidCallback onRemoveFile;

  const SubmitAssignmentTabletPickedFilePreview({
    super.key,
    required this.pickedFile,
    required this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppLightColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.insert_drive_file_outlined,
                color: AppLightColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  pickedFile.name,
                  style: font14w500.copyWith(
                    color: const Color(0xFF1E1E2D),
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                AppText(
                  '${(pickedFile.size / 1024).toStringAsFixed(1)} KB',
                  style: font10w400.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemoveFile,
            icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_tablet_picked_file_preview.dart';

/// Compact file picker for Homework Submission on Tablet Landscape.
class SubmitAssignmentTabletFilePicker extends StatelessWidget {
  final PlatformFile? pickedFile;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;

  const SubmitAssignmentTabletFilePicker({
    super.key,
    required this.pickedFile,
    required this.onPickFile,
    required this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'رفع ملف (اختياري)',
          style: font14w700.copyWith(
            color: const Color(0xFF1E1E2D),
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 6),
        if (pickedFile != null)
          SubmitAssignmentTabletPickedFilePreview(
            pickedFile: pickedFile!,
            onRemoveFile: onRemoveFile,
          )
        else
          BounceIt(
            onPressed: onPickFile,
            child: Container(
              height: 98,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    color: Color(0xFF94A3B8),
                    size: 26,
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    'اضغط هنا لاختيار ملف',
                    style: font14w500.copyWith(
                      color: const Color(0xFF475569),
                      fontSize: 12.5,
                    ),
                    alignment: AlignmentDirectional.center,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    'صور، مستندات، أو ملفات PDF',
                    style: font10w400.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontSize: 10.5,
                    ),
                    alignment: AlignmentDirectional.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

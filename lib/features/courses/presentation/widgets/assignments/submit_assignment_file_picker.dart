import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/theme/light_colors.dart';

class SubmitAssignmentFilePicker extends StatelessWidget {
  final XFile? pickedFile;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;

  const SubmitAssignmentFilePicker({
    super.key,
    required this.pickedFile,
    required this.onPickFile,
    required this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    if (pickedFile != null) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              color: AppLightColors.primary,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AppText(
                pickedFile!.name,
                style: font14w500.copyWith(color: const Color(0xFF374151)),
                maxLines: 1,
              ),
            ),
            IconButton(
              onPressed: onRemoveFile,
              icon: const Icon(Icons.close, color: Colors.red),
            ),
          ],
        ),
      );
    }

    return BounceIt(
      onPressed: onPickFile,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFD1D5DB),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: const Color(0xFF9CA3AF),
              size: 32.sp,
            ),
            SizedBox(height: 8.h),
            AppText(
              'اضغط هنا لاختيار ملف',
              style: font14w500.copyWith(color: const Color(0xFF6B7280)),
              alignment: AlignmentDirectional.center,
            ),
          ],
        ),
      ),
    );
  }
}

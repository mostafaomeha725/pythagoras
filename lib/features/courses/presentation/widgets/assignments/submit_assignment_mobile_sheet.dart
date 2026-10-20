import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_file_picker.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_notes_field.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_widgets.dart';

/// Layout for Homework Submission Bottom Sheet on Mobile and Portrait devices.
class SubmitAssignmentMobileSheet extends StatelessWidget {
  final String assignmentTitle;
  final TextEditingController notesController;
  final PlatformFile? pickedFile;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;
  final VoidCallback onMySubmissions;
  final VoidCallback onSubmit;

  const SubmitAssignmentMobileSheet({
    super.key,
    required this.assignmentTitle,
    required this.notesController,
    required this.pickedFile,
    required this.onPickFile,
    required this.onRemoveFile,
    required this.onMySubmissions,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SubmitAssignmentHeader(
              assignmentTitle: assignmentTitle,
              onMySubmissions: onMySubmissions,
            ),
            SizedBox(height: 24.h),
            SubmitAssignmentNotesField(controller: notesController),
            SizedBox(height: 24.h),
            AppText(
              'رفع ملف (اختياري)',
              style: font14w700.copyWith(color: const Color(0xFF1E1E2D)),
            ),
            SizedBox(height: 8.h),
            SubmitAssignmentFilePicker(
              pickedFile: pickedFile,
              onPickFile: onPickFile,
              onRemoveFile: onRemoveFile,
            ),
            SizedBox(height: 28.h),
            SubmitAssignmentButton(onSubmit: onSubmit),
            SizedBox(height: 28.h),
          ],
        ),
      ),
    );
  }
}

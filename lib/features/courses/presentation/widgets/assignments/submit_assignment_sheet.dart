import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/features/courses/presentation/cubit/submit_assignment/submit_assignment_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/submit_assignment/submit_assignment_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submission_list_sheet.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_file_picker.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_notes_field.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_widgets.dart';
import 'package:go_router/go_router.dart';

class SubmitAssignmentSheet extends StatefulWidget {
  final int assignmentId;
  final String assignmentTitle;
  final VoidCallback? onSubmitted;

  const SubmitAssignmentSheet({
    super.key,
    required this.assignmentId,
    required this.assignmentTitle,
    this.onSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    required int assignmentId,
    required String assignmentTitle,
    VoidCallback? onSubmitted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => sl<SubmitAssignmentCubit>(),
        child: SubmitAssignmentSheet(
          assignmentId: assignmentId,
          assignmentTitle: assignmentTitle,
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }

  @override
  State<SubmitAssignmentSheet> createState() => _SubmitAssignmentSheetState();
}

class _SubmitAssignmentSheetState extends State<SubmitAssignmentSheet> {
  final _notesController = TextEditingController();
  PlatformFile? _pickedFile;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  void _removeFile() => setState(() => _pickedFile = null);

  void _submit(BuildContext context) {
    final notes = _notesController.text.trim();
    if (notes.isEmpty && _pickedFile == null) {
      showError('الرجاء إضافة ملاحظات أو رفع ملف');
      return;
    }
    context.read<SubmitAssignmentCubit>().submit(
      assignmentId: widget.assignmentId,
      notes: notes.isEmpty ? null : notes,
      filePath: _pickedFile?.path,
      fileName: _pickedFile?.name,
    );
  }

  void _showMySubmissions(BuildContext context) {
    SubmissionListSheet.show(
      context,
      assignmentId: widget.assignmentId,
      assignmentTitle: widget.assignmentTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubmitAssignmentCubit, SubmitAssignmentState>(
      listener: (context, state) {
        if (state is SubmitAssignmentLoading) {
          EasyLoading.show(status: 'جاري التسليم...');
        } else if (state is SubmitAssignmentSuccess) {
          EasyLoading.dismiss();
          context.pop();
          showSuccess('تم تسليم الواجب بنجاح');
          widget.onSubmitted?.call();
        } else if (state is SubmitAssignmentError) {
          EasyLoading.dismiss();
          showError(state.message);
        }
      },
      child: Container(
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
                assignmentTitle: widget.assignmentTitle,
                onMySubmissions: () => _showMySubmissions(context),
              ),
              SizedBox(height: 24.h),
              SubmitAssignmentNotesField(controller: _notesController),
              SizedBox(height: 24.h),
              AppText(
                'رفع ملف (اختياري)',
                style: font14w700.copyWith(color: const Color(0xFF1E1E2D)),
              ),
              SizedBox(height: 8.h),
              SubmitAssignmentFilePicker(
                pickedFile: _pickedFile,
                onPickFile: _pickFile,
                onRemoveFile: _removeFile,
              ),
              SizedBox(height: 28.h),
              SubmitAssignmentButton(onSubmit: () => _submit(context)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/features/courses/presentation/cubit/submit_assignment/submit_assignment_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/submit_assignment/submit_assignment_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submission_list_sheet.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_sheet.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_source_sheet.dart';

/// Mixin encapsulating state, file picking, and submission logic for [SubmitAssignmentSheet].
mixin SubmitAssignmentMixin on State<SubmitAssignmentSheet> {
  final notesController = TextEditingController();
  PlatformFile? pickedFile;

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final length = await image.length();
        setState(() {
          pickedFile = PlatformFile(
            name: image.name,
            path: image.path,
            size: length,
          );
        });
      }
    } catch (_) {
      showError('تعذر فتح معرض الصور');
    }
  }

  Future<void> pickFromFileSystem() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.any);
      if (result != null && result.files.isNotEmpty) {
        setState(() => pickedFile = result.files.first);
      }
    } catch (_) {
      showError('تعذر فتح مستعرض الملفات');
    }
  }

  void dismissKeyboard() {
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void showFileSourceSheet() {
    dismissKeyboard();
    SubmitAssignmentSourceSheet.show(
      context,
      onPickGallery: pickFromGallery,
      onPickFileSystem: pickFromFileSystem,
    );
  }

  void removeFile() => setState(() => pickedFile = null);

  void submit() {
    dismissKeyboard();
    final notes = notesController.text.trim();
    if (notes.isEmpty && pickedFile == null) {
      showError('الرجاء إضافة ملاحظات أو رفع ملف');
      return;
    }
    context.read<SubmitAssignmentCubit>().submit(
      assignmentId: widget.assignmentId,
      notes: notes.isEmpty ? null : notes,
      filePath: pickedFile?.path,
      fileName: pickedFile?.name,
    );
  }

  void showMySubmissions() {
    dismissKeyboard();
    SubmissionListSheet.show(
      context,
      assignmentId: widget.assignmentId,
      assignmentTitle: widget.assignmentTitle,
    );
  }

  void handleStateListener(BuildContext context, SubmitAssignmentState state) {
    if (state is SubmitAssignmentLoading) {
      dismissKeyboard();
      EasyLoading.show(status: 'جاري التسليم...');
    } else if (state is SubmitAssignmentSuccess) {
      dismissKeyboard();
      EasyLoading.dismiss();
      context.pop();
      showSuccess('تم تسليم الواجب بنجاح');
      widget.onSubmitted?.call();
    } else if (state is SubmitAssignmentError) {
      EasyLoading.dismiss();
      showError(state.message);
    }
  }
}

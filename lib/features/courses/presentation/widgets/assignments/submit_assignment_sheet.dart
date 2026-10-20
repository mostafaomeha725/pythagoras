import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/courses/presentation/cubit/submit_assignment/submit_assignment_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/submit_assignment/submit_assignment_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_mixin.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_mobile_sheet.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_tablet_sheet.dart';

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

class _SubmitAssignmentSheetState extends State<SubmitAssignmentSheet>
    with SubmitAssignmentMixin {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTabletLandscape =
        size.width >= 900 && size.height >= 600 && size.width > size.height;

    return BlocListener<SubmitAssignmentCubit, SubmitAssignmentState>(
      listener: handleStateListener,
      child: GestureDetector(
        onTap: dismissKeyboard,
        behavior: HitTestBehavior.opaque,
        child: isTabletLandscape
            ? SubmitAssignmentTabletSheet(
                assignmentTitle: widget.assignmentTitle,
                notesController: notesController,
                pickedFile: pickedFile,
                onPickFile: showFileSourceSheet,
                onRemoveFile: removeFile,
                onMySubmissions: showMySubmissions,
                onSubmit: submit,
                onClose: () {
                  dismissKeyboard();
                  context.pop();
                },
              )
            : SubmitAssignmentMobileSheet(
                assignmentTitle: widget.assignmentTitle,
                notesController: notesController,
                pickedFile: pickedFile,
                onPickFile: showFileSourceSheet,
                onRemoveFile: removeFile,
                onMySubmissions: showMySubmissions,
                onSubmit: submit,
              ),
      ),
    );
  }
}

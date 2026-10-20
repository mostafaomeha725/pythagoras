import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_tablet_actions.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_tablet_file_picker.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_tablet_header.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_tablet_notes_field.dart';

/// Dedicated Tablet Landscape layout for Homework Submission Bottom Sheet.
class SubmitAssignmentTabletSheet extends StatelessWidget {
  final String assignmentTitle;
  final TextEditingController notesController;
  final PlatformFile? pickedFile;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;
  final VoidCallback onMySubmissions;
  final VoidCallback onSubmit;
  final VoidCallback onClose;

  const SubmitAssignmentTabletSheet({
    super.key,
    required this.assignmentTitle,
    required this.notesController,
    required this.pickedFile,
    required this.onPickFile,
    required this.onRemoveFile,
    required this.onMySubmissions,
    required this.onSubmit,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 680,
          maxHeight: screenHeight * 0.88,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 18,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 12,
            bottom: bottomInset > 0 ? bottomInset + 12 : 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SubmitAssignmentTabletHeader(
                assignmentTitle: assignmentTitle,
                onMySubmissions: onMySubmissions,
                onClose: onClose,
              ),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SubmitAssignmentTabletNotesField(
                          controller: notesController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SubmitAssignmentTabletFilePicker(
                          pickedFile: pickedFile,
                          onPickFile: onPickFile,
                          onRemoveFile: onRemoveFile,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SubmitAssignmentTabletActions(
                onSubmit: onSubmit,
                onCancel: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/services/native_download_service.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Tablet Landscape action buttons (View & Download) for assignments.
/// Uses explicit typography and paddings without ScreenUtil scaling.
class CourseTabletAssignmentActionButtons extends StatelessWidget {
  final CourseAssignment assignment;

  const CourseTabletAssignmentActionButtons({
    super.key,
    required this.assignment,
  });

  Future<void> _launchUrl(BuildContext context, String url) async {
    EasyLoading.show(status: 'جاري التحميل...');
    await Future.delayed(const Duration(milliseconds: 500));

    if (url.isNotEmpty && await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
      EasyLoading.dismiss();
    } else {
      EasyLoading.dismiss();
      if (context.mounted) {
        showError('لا يمكن فتح هذا الرابط');
      }
    }
  }

  void _onView(BuildContext context, String fileUrl) async {
    final fileName = assignment.assignmentFile?.name ?? '';
    final ext = fileName.split('.').last.toLowerCase();
    final isPdf = ext == 'pdf' || fileUrl.toLowerCase().endsWith('.pdf');

    final docExtensions = ['ppt', 'pptx', 'doc', 'docx', 'xls', 'xlsx'];
    final isDoc = docExtensions.contains(ext) ||
        docExtensions.any((e) => fileUrl.toLowerCase().endsWith('.$e'));

    if (isPdf) {
      EasyLoading.show(status: 'جاري فتح الملف...');
      await Future.delayed(const Duration(milliseconds: 200));
      EasyLoading.dismiss();
      if (context.mounted) {
        context.push(Routes.pdfViewerScreen, extra: {
          'url': fileUrl,
          'title': assignment.title,
        });
      }
    } else if (isDoc) {
      EasyLoading.show(status: 'جاري فتح العرض...');
      await Future.delayed(const Duration(milliseconds: 200));
      EasyLoading.dismiss();
      if (context.mounted) {
        context.push(Routes.webViewScreen, extra: {
          'url': fileUrl,
          'title': assignment.title,
        });
      }
    } else {
      _launchUrl(context, fileUrl);
    }
  }

  Future<void> _onDownload(String fileUrl) async {
    EasyLoading.show(status: 'جاري التحميل...');
    final fileName = fileUrl.split('/').last.split('?').first;
    final success = await NativeDownloadService().enqueueDownload(
      url: fileUrl,
      title: assignment.title,
      fileName: fileName.isNotEmpty ? fileName : 'assignment_file',
    );
    EasyLoading.dismiss();
    if (success && !kIsWeb && Platform.isIOS) {
      EasyLoading.showSuccess('تم الحفظ بنجاح');
    } else if (success) {
      EasyLoading.showSuccess('تم البدء في تحميل الملف');
    } else {
      EasyLoading.showError('فشل في بدء التحميل');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileUrl = assignment.assignmentFile?.url;
    if (fileUrl == null || fileUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Button
        BounceIt(
          onPressed: () => _onView(context, fileUrl),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppLightColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.visibility_outlined,
                  color: AppLightColors.primary,
                  size: 14,
                ),
                const SizedBox(width: 5),
                AppText(
                  'عرض الملف',
                  style: font12w700.copyWith(
                    color: AppLightColors.primary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Download Button
        BounceIt(
          onPressed: () => _onDownload(fileUrl),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.download_outlined,
                  color: Color(0xFF374151),
                  size: 14,
                ),
                const SizedBox(width: 5),
                AppText(
                  'تحميل الملف',
                  style: font12w700.copyWith(
                    color: const Color(0xFF374151),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

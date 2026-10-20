import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/core/services/native_download_service.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';

/// Top bar for PDF Viewer on Tablet Landscape.
/// Reuses [CourseDetailTabletTopBar] with PDF badge and download action.
class PdfViewerTabletTopBar extends StatelessWidget {
  final String title;
  final String url;

  const PdfViewerTabletTopBar({
    super.key,
    required this.title,
    required this.url,
  });

  Future<void> _onDownload() async {
    EasyLoading.show(status: 'جاري التحميل...');
    final fileName = url.split('/').last.split('?').first;
    final success = await NativeDownloadService().enqueueDownload(
      url: url,
      title: title,
      fileName: fileName.isNotEmpty ? fileName : 'document.pdf',
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
    return CourseDetailTabletTopBar(
      title: title,
      titleFontSize: 18,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_as_pdf_outlined,
              color: Color(0xFFEF4444),
              size: 16,
            ),
            const SizedBox(width: 4),
            AppText(
              'PDF',
              style: font12w700.copyWith(
                color: const Color(0xFFEF4444),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      trailing: BounceIt(
        onPressed: _onDownload,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppLightColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.file_download_outlined,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              AppText(
                'تحميل الملف',
                style: font12w700.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

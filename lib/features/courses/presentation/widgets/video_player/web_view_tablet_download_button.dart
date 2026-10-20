import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/core/services/native_download_service.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Download action button for WebView Tablet Top Bar.
/// Encapsulates _onDownload logic with NativeDownloadService and EasyLoading.
class WebViewTabletDownloadButton extends StatelessWidget {
  final String url;
  final String title;

  const WebViewTabletDownloadButton({
    super.key,
    required this.url,
    required this.title,
  });

  Future<void> _onDownload() async {
    EasyLoading.show(status: 'جاري التحميل...');
    final cleanName = url.split('/').last.split('?').first;
    final fileName = cleanName.isNotEmpty ? cleanName : 'document';
    final success = await NativeDownloadService().enqueueDownload(
      url: url,
      title: title,
      fileName: fileName,
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
    return BounceIt(
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
    );
  }
}

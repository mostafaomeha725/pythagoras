import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/services/native_download_service.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

class AssignmentCardDownloadButton extends StatelessWidget {
  final String fileUrl;
  final String title;

  const AssignmentCardDownloadButton({
    super.key,
    required this.fileUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BounceIt(
      onPressed: () async {
        EasyLoading.show(status: 'جاري التحميل...');
        final fileName = fileUrl.split('/').last.split('?').first;
        final success = await NativeDownloadService().enqueueDownload(
          url: fileUrl,
          title: title,
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
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              'تحميل',
              style: font13w700.copyWith(
                color: const Color(0xFF374151),
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.download_outlined,
              color: const Color(0xFF374151),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}

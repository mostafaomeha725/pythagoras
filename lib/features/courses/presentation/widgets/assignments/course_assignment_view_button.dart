import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';

class CourseAssignmentViewButton extends StatelessWidget {
  final CourseAssignment assignment;

  const CourseAssignmentViewButton({super.key, required this.assignment});

  Future<void> _launchUrl(BuildContext context, String url) async {
    EasyLoading.show(status: 'جاري التحميل...');
    
    // Add a small delay for UX so the loading shows before freezing if external app opens
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

  @override
  Widget build(BuildContext context) {
    final fileUrl = assignment.assignmentFile?.url;
    if (fileUrl == null || fileUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return BounceIt(
      onPressed: () async {
        final fileName = assignment.assignmentFile?.name ?? '';
        final ext = fileName.split('.').last.toLowerCase();
        final isPdf = ext == 'pdf' || fileUrl.toLowerCase().endsWith('.pdf');
        
        final docExtensions = ['ppt', 'pptx', 'doc', 'docx', 'xls', 'xlsx'];
        final isDoc = docExtensions.contains(ext) || docExtensions.any((e) => fileUrl.toLowerCase().endsWith('.$e'));
        
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
          // If it's an image or something else, use external viewer
          _launchUrl(context, fileUrl);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: AppLightColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility_outlined,
              color: AppLightColors.primary,
              size: 16.sp,
            ),
            SizedBox(width: 4.w),
            AppText(
              'عرض',
              style: font13w700.copyWith(color: AppLightColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

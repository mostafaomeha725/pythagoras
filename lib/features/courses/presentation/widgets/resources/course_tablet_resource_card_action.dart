import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';
import 'package:pythagoras/features/courses/presentation/cubit/download_resource/download_resource_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/download_resource/download_resource_state.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Resource card actions (View & Download) optimized for Tablet Landscape.
class CourseTabletResourceCardAction extends StatelessWidget {
  final CourseResource resource;

  const CourseTabletResourceCardAction({super.key, required this.resource});

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

  void _onView(BuildContext context) async {
    if (resource.isPdf) {
      EasyLoading.show(status: 'جاري فتح الملف...');
      await Future.delayed(const Duration(milliseconds: 200));
      EasyLoading.dismiss();
      if (context.mounted) {
        context.push(
          Routes.pdfViewerScreen,
          extra: {'url': resource.fileUrl, 'title': resource.title},
        );
      }
    } else if (resource.isDoc) {
      EasyLoading.show(status: 'جاري فتح العرض...');
      await Future.delayed(const Duration(milliseconds: 200));
      EasyLoading.dismiss();
      if (context.mounted) {
        context.push(
          Routes.webViewScreen,
          extra: {'url': resource.fileUrl, 'title': resource.title},
        );
      }
    } else {
      _launchUrl(context, resource.fileUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DownloadResourceCubit>(),
      child: BlocListener<DownloadResourceCubit, DownloadResourceState>(
        listener: (context, state) {
          if (state is DownloadResourceLoading) {
            EasyLoading.show(status: 'جاري التحضير...');
          } else if (state is DownloadResourceSuccess) {
            EasyLoading.dismiss();
            if (!kIsWeb && Platform.isIOS) {
              showSuccess('تم الحفظ بنجاح');
            } else {
              showSuccess('تم البدء في تحميل الملف (انظر قائمة الإشعارات)');
            }
          } else if (state is DownloadResourceError) {
            EasyLoading.dismiss();
            showError(state.message);
          }
        },
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // View Button
            BounceIt(
              onPressed: () => _onView(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
                      size: 15,
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
            // Download Button
            BlocBuilder<DownloadResourceCubit, DownloadResourceState>(
              builder: (context, state) {
                return BounceIt(
                  onPressed: state is DownloadResourceLoading
                      ? null
                      : () {
                          final ext = resource.fileExtension.toLowerCase();
                          final title = resource.title;
                          final fileName = '${title.replaceAll(' ', '_')}.$ext';
                          context
                              .read<DownloadResourceCubit>()
                              .downloadResource(
                                resourceId: resource.id,
                                title: title,
                                fileName: fileName,
                              );
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
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
                          size: 15,
                        ),
                        const SizedBox(width: 5),
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
              },
            ),
          ],
        ),
      ),
    );
  }
}

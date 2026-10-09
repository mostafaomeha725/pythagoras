import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/courses/presentation/cubit/download_resource/download_resource_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/download_resource/download_resource_state.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_resource_view_button.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_resource_download_button.dart';

class CourseResourceCardAction extends StatelessWidget {
  final CourseResource resource;
  const CourseResourceCardAction({super.key, required this.resource});

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CourseResourceViewButton(resource: resource),
            SizedBox(width: 8.w),
            CourseResourceDownloadButton(resource: resource),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/presentation/cubit/download_resource/download_resource_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/download_resource/download_resource_state.dart';

class CourseResourceDownloadButton extends StatelessWidget {
  final CourseResource resource;

  const CourseResourceDownloadButton({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadResourceCubit, DownloadResourceState>(
      builder: (context, state) {
        return BounceIt(
          onPressed: state is DownloadResourceLoading
              ? null
              : () {
                  final ext = resource.file?.extension?.toLowerCase() ?? resource.type?.toLowerCase() ?? 'file';
                  final title = resource.title;
                  final fileName = '${title.replaceAll(' ', '_')}.$ext';
                  
                  context.read<DownloadResourceCubit>().downloadResource(
                        resourceId: resource.id,
                        title: title,
                        fileName: fileName,
                      );
                },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 10.h,
            ),
            decoration: BoxDecoration(
              color: AppLightColors.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.file_download_outlined,
                  color: Colors.white,
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                AppText(
                  'تحميل الملف',
                  style: font12w700.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

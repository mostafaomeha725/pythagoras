import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pythagoras/core/routes/route_paths.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/profile/domain/entities/my_course_enrollment.dart';

class MyCourseActionButton extends StatelessWidget {
  final MyCourseEnrollment enrollment;

  const MyCourseActionButton({super.key, required this.enrollment});

  @override
  Widget build(BuildContext context) {
    return BounceIt(
      onPressed: () {
        context.push(
          Routes.courseDetailScreen,
          extra: {
            'id': enrollment.course.id,
            'title': enrollment.course.title,
            'isEnrolled': true,
          },
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: AppLightColors.primary,
          borderRadius: BorderRadius.circular(14.r),
        ),
        alignment: Alignment.center,
        child: AppText(
          'متابعة الدورة',
          style: font16w700.copyWith(color: Colors.white),
          alignment: AlignmentDirectional.center,
        ),
      ),
    );
  }
}

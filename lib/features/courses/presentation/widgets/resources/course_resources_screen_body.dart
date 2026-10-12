import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_resources/course_resources_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_resources/course_resources_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_resource_card.dart';
import 'package:pythagoras/core/widgets/empty_state_widget.dart';

import 'package:pythagoras/core/widgets/no_internet_widget.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_resources_shimmer.dart';

class CourseResourcesScreenBody extends StatelessWidget {
  final CourseDetail course;

  const CourseResourcesScreenBody({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CourseResourcesCubit>()..getResources(course.id),
      child: BlocBuilder<CourseResourcesCubit, CourseResourcesState>(
        builder: (context, state) {
          if (state is CourseResourcesLoading) {
            return const CourseResourcesShimmer();
          }

          if (state is CourseResourcesError) {
            return NoInternetWidget(
              message: state.message,
              onRetry: () => context
                  .read<CourseResourcesCubit>()
                  .getResources(course.id),
            );
          }

          final resources = state is CourseResourcesLoaded
              ? state.resources
              : [];

          final totalCount = resources.length;

          return ListView(
            padding: EdgeInsets.all(24.w),
            physics: const BouncingScrollPhysics(),
            children: [
              // Top Header Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Right Side
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'موارد المقرر',
                        style: font24w700.copyWith(
                          color: const Color(0xFF1E1E2D),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      AppText(
                        'كل ما تحتاجه للمذاكرة',
                        style: font12w500.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  // Left Side Pill
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF4FA),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_open_outlined,
                          color: const Color(0xFF832561),
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),

                        AppText(
                          '$totalCount ملفات',
                          style: font12w700.copyWith(
                            color: const Color(0xFF832561),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'الملفات التعليمية',
                    style: font20w700.copyWith(color: const Color(0xFF1E1E2D)),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF4FA),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: AppText(
                      'محدّثة',
                      style: font12w700.copyWith(
                        color: const Color(0xFF832561),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              if (resources.isEmpty && state is CourseResourcesLoaded)
                Padding(
                  padding: EdgeInsets.only(top: 40.h),
                  child: const EmptyStateWidget(
                    message: 'لا توجد ملازم حالياً',
                    icon: Icons.description_outlined,
                  ),
                )
              else
                ...resources.map((res) => CourseResourceCard(resource: res)),

              SizedBox(height: 40.h),
            ],
          );
        },
      ),
    );
  }
}

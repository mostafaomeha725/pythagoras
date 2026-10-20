import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/core/widgets/no_internet_widget.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_resources/course_resources_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_resources/course_resources_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/course_details/course_detail_tablet_top_bar.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_resources_shimmer.dart';
import 'package:pythagoras/features/courses/presentation/widgets/resources/course_tablet_resource_card.dart';

/// Dedicated Tablet layout for [CourseResourcesScreen] across Small and Large Tablets.
class CourseResourcesTabletLandscape extends StatelessWidget {
  final CourseDetail course;

  const CourseResourcesTabletLandscape({super.key, required this.course});

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
              onRetry: () =>
                  context.read<CourseResourcesCubit>().getResources(course.id),
            );
          }

          final resources =
              state is CourseResourcesLoaded ? state.resources : [];
          final totalCount = resources.length;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isLargeTablet = constraints.maxWidth >= 1100;
              final isSmallTablet = !isLargeTablet;

              final horizontalPadding = isLargeTablet
                  ? 24.0
                  : (constraints.maxWidth < 650 ? 16.0 : 20.0);

              final int gridColumns = constraints.maxWidth >= 1050
                  ? 3
                  : (constraints.maxWidth >= 600 ? 2 : 1);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Fixed Top Bar with back button and screen title
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: isSmallTablet ? 4.0 : 8.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1160),
                        child: CourseDetailTabletTopBar(
                          title: 'الموارد',
                          titleFontSize: isSmallTablet ? 18 : 20,
                          padding: isSmallTablet
                              ? const EdgeInsets.symmetric(vertical: 4)
                              : null,
                        ),
                      ),
                    ),
                  ),

                  // Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 4.0,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1160),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Top Header Section Card
                              _buildHeaderSection(isSmallTablet, totalCount),

                              SizedBox(height: isSmallTablet ? 16 : 22),

                              // Section Title
                              _buildSectionTitle(isSmallTablet),

                              SizedBox(height: isSmallTablet ? 12 : 16),

                              // Resources Content
                              if (resources.isEmpty &&
                                  state is CourseResourcesLoaded)
                                _buildTabletEmptyState(
                                  isSmallTablet: isSmallTablet,
                                )
                              else
                                _buildResourcesGrid(
                                  resources: resources,
                                  columns: gridColumns,
                                  spacing: isSmallTablet ? 12.0 : 16.0,
                                ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(bool isSmallTablet, int totalCount) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallTablet ? 16 : 20,
        vertical: isSmallTablet ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'موارد المقرر',
                style: font20w700.copyWith(
                  color: const Color(0xFF1E1E2D),
                  fontSize: isSmallTablet ? 18 : 22,
                ),
              ),
              const SizedBox(height: 4),
              AppText(
                'كل ما تحتاجه للمذاكرة',
                style: font12w500.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: isSmallTablet ? 12 : 13,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallTablet ? 12 : 14,
              vertical: isSmallTablet ? 6 : 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF4FA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.folder_open_outlined,
                  color: const Color(0xFF832561),
                  size: isSmallTablet ? 15 : 16,
                ),
                const SizedBox(width: 6),
                AppText(
                  '$totalCount ملفات',
                  style: font12w700.copyWith(
                    color: const Color(0xFF832561),
                    fontSize: isSmallTablet ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(bool isSmallTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          'الملفات التعليمية',
          style: font20w700.copyWith(
            color: const Color(0xFF1E1E2D),
            fontSize: isSmallTablet ? 16 : 18,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallTablet ? 10 : 12,
            vertical: isSmallTablet ? 4 : 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF4FA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: AppText(
            'محدّثة',
            style: font12w700.copyWith(
              color: const Color(0xFF832561),
              fontSize: isSmallTablet ? 11 : 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletEmptyState({required bool isSmallTablet}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: isSmallTablet ? 14 : 20),
      padding: EdgeInsets.symmetric(
        vertical: isSmallTablet ? 28 : 36,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isSmallTablet ? 58 : 66,
            height: isSmallTablet ? 58 : 66,
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.description_outlined,
                size: isSmallTablet ? 28 : 32,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
          SizedBox(height: isSmallTablet ? 12 : 16),
          AppText(
            'لا توجد ملازم حالياً',
            style: font16w700.copyWith(
              color: const Color(0xFF374151),
              fontSize: isSmallTablet ? 15 : 16,
            ),
            textAlign: TextAlign.center,
            alignment: AlignmentDirectional.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesGrid({
    required List<dynamic> resources,
    required int columns,
    required double spacing,
  }) {
    if (columns <= 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: resources
            .map((res) => CourseTabletResourceCard(resource: res))
            .toList(),
      );
    }

    final cols = List.generate(columns, (_) => <Widget>[]);
    for (int i = 0; i < resources.length; i++) {
      cols[i % columns].add(CourseTabletResourceCard(resource: resources[i]));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < columns; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cols[i],
            ),
          ),
        ],
      ],
    );
  }
}

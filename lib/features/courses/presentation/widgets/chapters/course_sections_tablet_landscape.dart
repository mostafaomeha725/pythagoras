import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/models/course_section.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_section_tablet_tile.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_sections_tablet_top_bar.dart';

/// Dedicated Tablet Landscape layout for [CourseSectionsScreen].
/// Features:
/// - Top bar with back button and screen title
/// - Wide course title banner card
/// - 2-column balanced grid of course sections matching the design reference
class CourseSectionsTabletLandscape extends StatelessWidget {
  final CourseDetail course;
  final int? selectedChapterId;

  const CourseSectionsTabletLandscape({
    super.key,
    required this.course,
    this.selectedChapterId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, screenConstraints) {
        final isLargeTablet = screenConstraints.maxWidth >= 1150;
        final isSmallTablet = !isLargeTablet;
        final isLandscape =
            screenConstraints.maxWidth > screenConstraints.maxHeight;

        final horizontalPadding = isLargeTablet
            ? 24.0
            : (screenConstraints.maxWidth < 650 ? 16.0 : 20.0);

        final topBarPadding = isLargeTablet
            ? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0)
            : EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 4.0,
              );

        final topBarTitleFontSize = isLargeTablet ? 20.0 : 18.0;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Bar ─────────────────────────────────────────
              Padding(
                padding: topBarPadding,
                child: CourseSectionsTabletTopBar(
                  titleFontSize: topBarTitleFontSize,
                ),
              ),

              // ── Scrollable Body ─────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isLargeTablet ? 4.0 : 2.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 2),

                      // ── Course Banner Card ──────────────────────
                      _buildBannerCard(isSmallTablet),

                      SizedBox(height: isSmallTablet ? 12 : 14),

                      // ── Sections Grid ───────────────────────────
                      _buildSectionsGrid(
                        screenConstraints,
                        isLargeTablet,
                        isLandscape,
                      ),

                      SizedBox(height: isSmallTablet ? 24 : 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBannerCard(bool isSmallTablet) {
    return Container(
      width: double.infinity,
      padding: isSmallTablet
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppLightColors.primary, Color(0xFF9C2A7A)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(isSmallTablet ? 14 : 18),
        boxShadow: [
          BoxShadow(
            color: AppLightColors.primary.withValues(alpha: 0.28),
            blurRadius: isSmallTablet ? 10 : 14,
            offset: Offset(0, isSmallTablet ? 3 : 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  course.title,
                  style: font20w700.copyWith(
                    color: Colors.white,
                    fontSize: isSmallTablet ? 16 : 20,
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: isSmallTablet ? 3 : 4),
                AppText(
                  'اختر القسم الذي تريد متابعته',
                  style: font14w500.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: isSmallTablet ? 12 : 13,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isSmallTablet ? 10 : 14),
          Container(
            width: isSmallTablet ? 38 : 46,
            height: isSmallTablet ? 38 : 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.school_outlined,
                color: Colors.white,
                size: isSmallTablet ? 20 : 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsGrid(
    BoxConstraints constraints,
    bool isLargeTablet,
    bool isLandscape,
  ) {
    final int crossAxisCount;
    final double childAspectRatio;
    final double spacing;
    final double tileTitleFontSize;
    final EdgeInsetsGeometry tilePadding;
    final double tileBorderRadius;

    if (isLargeTablet) {
      // Large Tablet layout: 100% identical to original
      crossAxisCount = 2;
      childAspectRatio = constraints.maxWidth >= 900
          ? 2.3
          : (constraints.maxWidth >= 700 ? 2.1 : 1.85);
      spacing = 16.0;
      tileTitleFontSize = 16.0;
      tilePadding = const EdgeInsets.symmetric(horizontal: 14, vertical: 14);
      tileBorderRadius = 18.0;
    } else {
      // Small Tablet layout (Portrait & Landscape)
      spacing = 12.0;
      tileBorderRadius = 14.0;

      if (isLandscape) {
        // Landscape (e.g. 1024x600 WSVGA, 1024x768):
        // 4 columns to utilize wide space balanced in a single row without cut-off
        crossAxisCount = 4;
        childAspectRatio = constraints.maxWidth >= 950 ? 1.55 : 1.45;
        tileTitleFontSize = 14.0;
        tilePadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 10);
      } else {
        // Portrait (e.g. 768x1024, 600x1024):
        // 2 columns with reduced height matching vertical space
        crossAxisCount = 2;
        childAspectRatio = constraints.maxWidth >= 700 ? 2.1 : 1.75;
        tileTitleFontSize = 15.0;
        tilePadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: CourseSection.defaultSections.length,
      itemBuilder: (context, index) {
        final section = CourseSection.defaultSections[index];
        return CourseSectionTabletTile(
          section: section,
          course: course,
          selectedChapterId: selectedChapterId,
          titleFontSize: tileTitleFontSize,
          padding: tilePadding,
          borderRadius: tileBorderRadius,
        );
      },
    );
  }
}

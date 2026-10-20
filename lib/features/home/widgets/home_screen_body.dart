import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pythagoras/core/utils/responsive_helper.dart';

import 'home_features.dart';
import 'home_header.dart';
import 'home_hero_card.dart';
import 'home_statistics.dart';
import 'home_tablet_landscape.dart';

class HomeScreenBody extends StatelessWidget {
  final VoidCallback onNavigateToCourses;

  const HomeScreenBody({super.key, required this.onNavigateToCourses});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet =
            ResponsiveHelper.isTablet(context) ||
            (constraints.maxWidth >= 900 &&
                constraints.maxWidth > constraints.maxHeight);

        if (isTablet) {
          final isPortrait = ResponsiveHelper.isPortrait(context, constraints);
          return HomeTabletLandscape(
            onNavigateToCourses: onNavigateToCourses,
            bottomPadding: isPortrait ? 110 : 28,
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HomeHeader(),
                HomeHeroCard(onStartLearning: onNavigateToCourses),
                SizedBox(height: 32.h),
                const HomeStatistics(),
                SizedBox(height: 32.h),
                const HomeFeatures(),
                SizedBox(
                  height: 120.h,
                ), // Extra padding for Bottom Navigation Bar
              ],
            ),
          ),
        );
      },
    );
  }
}

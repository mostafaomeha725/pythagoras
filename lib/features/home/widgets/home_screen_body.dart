import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'home_features.dart';
import 'home_header.dart';
import 'home_hero_card.dart';
import 'home_statistics.dart';

class HomeScreenBody extends StatelessWidget {
  final VoidCallback onNavigateToCourses;
  
  const HomeScreenBody({
    super.key,
    required this.onNavigateToCourses,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HomeHeader(),
            HomeHeroCard(
              onStartLearning: onNavigateToCourses,
            ),
            SizedBox(height: 32.h),
            const HomeStatistics(),
            SizedBox(height: 32.h),
            const HomeFeatures(),
            SizedBox(height: 120.h), // Extra padding for Bottom Navigation Bar
          ],
        ),
      ),
    );
  }
}

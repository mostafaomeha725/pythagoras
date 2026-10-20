import 'package:flutter/material.dart';
import 'home_tablet_features.dart';
import 'home_tablet_header.dart';
import 'home_tablet_hero_card.dart';
import 'home_tablet_statistics.dart';

/// Full Tablet Landscape body for Home screen.
class HomeTabletLandscape extends StatelessWidget {
  final VoidCallback onNavigateToCourses;
  final double bottomPadding;

  const HomeTabletLandscape({
    super.key,
    required this.onNavigateToCourses,
    this.bottomPadding = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HomeTabletHeader(),
            HomeTabletHeroCard(onStartLearning: onNavigateToCourses),
            const SizedBox(height: 24),
            const HomeTabletStatistics(),
            const SizedBox(height: 24),
            const HomeTabletFeatures(),
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}

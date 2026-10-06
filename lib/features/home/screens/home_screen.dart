import 'package:flutter/material.dart';
import 'package:pythagoras/core/constants/app_assets.dart';
import 'package:pythagoras/core/widgets/navigation_state.dart';

import 'home_screen_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NavigationState _navState = NavigationState(initialIndex: 1);

  final List<Map<String, dynamic>> _navItems = [
    {"imageAsset": Assets.home, "label": "الرئيسية"},
    {"imageAsset": Assets.course, "label": "الدورات"},
    {"imageAsset": Assets.profile, "label": "حسابي"},
  ];

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return HomeScreenContent(navState: _navState, navItems: _navItems);
      },
    );
  }
}

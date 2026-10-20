import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/widgets/custom_bottom_navbar.dart';
import 'package:pythagoras/core/widgets/navigation_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';

import '../widgets/home_screen_body.dart';
import 'package:pythagoras/features/courses/presentation/screens/courses_screen.dart';
import 'package:pythagoras/features/profile/presentation/screens/profile_screen.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/features/home/widgets/tablet_navigation_sidebar.dart';

import 'package:pythagoras/core/utils/responsive_helper.dart';

class HomeScreenContent extends StatefulWidget {
  final NavigationState navState;
  final List<Map<String, dynamic>> navItems;

  const HomeScreenContent({
    super.key,
    required this.navState,
    required this.navItems,
  });

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialDataSequentially(context);
    });
  }

  Future<void> _fetchInitialDataSequentially(BuildContext context) async {
    final coursesCubit = context.read<CoursesListCubit>();
    final classesCubit = context.read<ClassesCubit>();
    final profileCubit = context.read<ProfileCubit>();

    await coursesCubit.fetchCourses();
    await classesCubit.fetchClasses();

    final prefs = sl<PreferencesStorage>();
    final token = prefs.getUserToken();
    if (token != null && token.isNotEmpty) {
      await profileCubit.getAccountInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletLandscape = ResponsiveHelper.isTabletLandscape(
          context,
          constraints,
        );

        if (isTabletLandscape) {
          return Scaffold(
            backgroundColor: const Color(0xFFFAFAFA),
            body: Row(
              children: [
                TabletNavigationSidebar(
                  navItems: widget.navItems,
                  selectedIndex: widget.navState.selectedIndex,
                  onItemTapped: (index) {
                    widget.navState.onItemTapped(index, () {
                      setState(() {});
                    });
                  },
                ),
                Expanded(
                  child: IndexedStack(
                    index: widget.navState.selectedIndex,
                    children: [
                      HomeScreenBody(
                        onNavigateToCourses: () {
                          widget.navState.onItemTapped(1, () {
                            setState(() {});
                          });
                        },
                      ),
                      const CoursesScreen(),
                      const ProfileScreen(),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: widget.navState.selectedIndex,
            children: [
              HomeScreenBody(
                onNavigateToCourses: () {
                  widget.navState.onItemTapped(1, () {
                    setState(() {});
                  });
                },
              ),
              const CoursesScreen(),
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(
            navItems: widget.navItems,
            navState: widget.navState,
            onItemTapped: (index) {
              widget.navState.onItemTapped(index, () {
                setState(() {});
              });
            },
          ),
        );
      },
    );
  }
}

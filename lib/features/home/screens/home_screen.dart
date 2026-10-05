import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/constants/app_assets.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/widgets/navigation_state.dart';
import 'package:pythagoras/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_classes_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';
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
    {"imageAsset": Assets.course, "label": "دوراتي"},
    {"imageAsset": Assets.profile, "label": "حسابي"},
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ClassesCubit(
            GetClassesUseCase(
              CoursesRepositoryImpl(networkService: sl(), cacheService: sl()),
            ),
          ),
        ),
        BlocProvider(create: (context) => sl<CoursesListCubit>()),
        BlocProvider(create: (context) => sl<ProfileCubit>()),
      ],
      child: Builder(
        builder: (context) {
          return HomeScreenContent(navState: _navState, navItems: _navItems);
        },
      ),
    );
  }
}

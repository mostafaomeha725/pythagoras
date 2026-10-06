import 'package:pythagoras/core/routes/app_routes.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pythagoras/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_classes_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';

import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:chucker_flutter/chucker_flutter.dart';

import 'package:pythagoras/core/cache/hive_boxes.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(HiveBoxes.cacheBox);
  await initializeDateFormatting('ar', null);
  await ServiceLocator().initDependencies();

  // final prefs = await SharedPreferences.getInstance();
  // await prefs.clear();
  configureEasyLoading();
  ChuckerFlutter.showNotification = false;
  runApp(const DefaultApp());
}

class DefaultApp extends StatelessWidget {
  const DefaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = createRouter();

    return ScreenUtilInit(
      designSize: const Size(420, 910),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
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
          child: MaterialApp.router(
            title: 'Pythagoras',
            debugShowCheckedModeBanner: false,
            builder: EasyLoading.init(
              builder: (context, child) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                );
              },
            ),
            theme: ThemeData(
              scaffoldBackgroundColor: AppLightColors.defaultBackground,
              useMaterial3: true,
            ),
            routerConfig: router,
          ),
        );
      },
    );
  }
}

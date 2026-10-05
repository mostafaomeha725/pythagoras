import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/auth/presentation/screens/login_screen.dart';
import 'package:pythagoras/features/auth/presentation/screens/choose_user_type_screen.dart';
import 'package:pythagoras/features/auth/presentation/screens/register_screen.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:pythagoras/features/courses/presentation/screens/course_sections_screen.dart';
import 'package:pythagoras/features/courses/presentation/screens/course_recorded_lessons_screen.dart';
import 'package:pythagoras/features/courses/presentation/screens/course_online_lessons_screen.dart';
import 'package:pythagoras/features/courses/presentation/screens/course_exams_screen.dart';
import 'package:pythagoras/features/courses/presentation/screens/course_resources_screen.dart';
import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';
import 'package:pythagoras/features/profile/presentation/screens/my_courses_screen.dart';
import 'package:pythagoras/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:pythagoras/features/profile/presentation/screens/contact_us_screen.dart';
import 'package:pythagoras/features/home/screens/home_screen.dart';
import 'package:pythagoras/features/splash/presentation/screens/splash_screen.dart';
import 'package:pythagoras/features/courses/presentation/screens/pdf_viewer_screen.dart';
import 'package:pythagoras/features/courses/presentation/screens/webview_screen.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import '/core/env.dart';
import 'route_observer.dart';
import 'route_paths.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final CustomGoRouterObserver customGoRouterObserver = CustomGoRouterObserver();

GoRouter createRouter() {
  final prefs = sl<PreferencesStorage>();
  final token = prefs.getUserToken();
  final isLoggedIn = token != null && token.isNotEmpty;

  return GoRouter(
    initialLocation: isLoggedIn
        ? Routes.mainNavigationScreen
        : Routes.loginScreen,
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    observers: [
      if (isDevEnviroment()) ChuckerFlutter.navigatorObserver,
      // customGoRouterObserver,
    ],
    routes: [
      GoRoute(
        path: Routes.splashScreen,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.loginScreen,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.chooseUserTypeScreen,
        builder: (context, state) => const ChooseUserTypeScreen(),
      ),
      GoRoute(
        path: Routes.registerScreen,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.mainNavigationScreen,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.courseDetailScreen,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final courseId = int.tryParse(extra['id'].toString()) ?? 0;
          final courseTitle = extra['title'] as String;
          final isEnrolled = extra['isEnrolled'] as bool? ?? false;
          return CourseDetailScreen(
            courseId: courseId,
            courseTitle: courseTitle,
            isEnrolled: isEnrolled,
          );
        },
      ),
      GoRoute(
        path: Routes.courseSectionsScreen,
        builder: (context, state) {
          if (state.extra is CourseDetail) {
            return CourseSectionsScreen(course: state.extra as CourseDetail);
          }
          final extra = state.extra as Map<String, dynamic>;
          return CourseSectionsScreen(
            course: extra['course'] as CourseDetail,
            selectedChapterId: extra['selectedChapterId'] as int?,
          );
        },
      ),
      GoRoute(
        path: Routes.courseRecordedLessonsScreen,
        builder: (context, state) {
          if (state.extra is CourseDetail) {
            return CourseRecordedLessonsScreen(
              course: state.extra as CourseDetail,
            );
          }
          final extra = state.extra as Map<String, dynamic>;
          return CourseRecordedLessonsScreen(
            course: extra['course'] as CourseDetail,
            selectedChapterId: extra['selectedChapterId'] as int?,
          );
        },
      ),
      GoRoute(
        path: Routes.courseOnlineLessonsScreen,
        builder: (context, state) {
          final course = state.extra as CourseDetail;
          return CourseOnlineLessonsScreen(course: course);
        },
      ),
      GoRoute(
        path: Routes.courseExamsScreen,
        builder: (context, state) {
          final course = state.extra as CourseDetail;
          return CourseExamsScreen(course: course);
        },
      ),
      GoRoute(
        path: Routes.courseResourcesScreen,
        builder: (context, state) {
          final course = state.extra as CourseDetail;
          return CourseResourcesScreen(course: course);
        },
      ),
      GoRoute(
        path: Routes.myCoursesScreen,
        builder: (context, state) => const MyCoursesScreen(),
      ),
      GoRoute(
        path: Routes.editProfileScreen,
        builder: (context, state) {
          final userProfile = state.extra as UserProfile?;
          return EditProfileScreen(userProfile: userProfile);
        },
      ),
      GoRoute(
        path: Routes.contactUsScreen,
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: Routes.pdfViewerScreen,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final url = extra['url'] as String;
          final title = extra['title'] as String;
          return PdfViewerScreen(url: url, title: title);
        },
      ),
      GoRoute(
        path: Routes.webViewScreen,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final url = extra['url'] as String;
          final title = extra['title'] as String;
          return WebViewScreen(url: url, title: title);
        },
      ),
    ],
  );
}

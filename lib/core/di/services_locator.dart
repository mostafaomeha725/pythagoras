import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pythagoras/core/cache/hive_boxes.dart';
import 'package:pythagoras/core/cache/hive_storage.dart';
import 'package:pythagoras/core/network/network_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pythagoras/features/auth/domain/repositories/auth_repository.dart';
import 'package:pythagoras/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pythagoras/features/auth/domain/usecases/login_use_case.dart';
import 'package:pythagoras/features/auth/domain/usecases/logout_use_case.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:pythagoras/features/auth/domain/usecases/get_whatsapp_register_url_use_case.dart';
import 'package:pythagoras/features/auth/presentation/cubit/whatsapp_register_cubit.dart';
import 'package:pythagoras/features/profile/domain/repositories/profile_repository.dart';
import 'package:pythagoras/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:pythagoras/features/profile/domain/usecases/get_account_info_use_case.dart';
import 'package:pythagoras/features/profile/domain/usecases/upload_profile_picture_use_case.dart';
import 'package:pythagoras/features/profile/domain/usecases/update_personal_profile_use_case.dart';
import 'package:pythagoras/features/profile/domain/usecases/get_my_courses_use_case.dart';
import 'package:pythagoras/features/profile/domain/usecases/submit_contact_us_use_case.dart';
import 'package:pythagoras/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/edit_profile/edit_profile_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/my_courses/my_courses_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/contact_us/contact_us_cubit.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';
import 'package:pythagoras/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_classes_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_courses_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_cubit.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_course_details_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_course_curriculum_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_course_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_chapter_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_course_assignments_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_assignment_details_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/submit_assignment_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_assignment_submissions_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_course_quizzes_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_quiz_details_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_quiz_questions_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/start_quiz_attempt_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/submit_answer_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/submit_quiz_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_quiz_result_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_course_reviews_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/add_course_review_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_reviews/course_reviews_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/add_course_review/add_course_review_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_exams/course_exams_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/submit_assignment/submit_assignment_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/quiz/quiz_cubit.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_live_sessions_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_live_sessions/course_live_sessions_cubit.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_course_resources_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_resources/course_resources_cubit.dart';
import 'package:pythagoras/features/courses/domain/use_cases/download_resource_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/download_resource/download_resource_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/chapter_videos/chapter_videos_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/complete_video/complete_video_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/complete_lesson/complete_lesson_cubit.dart';

final sl = GetIt.instance;

class ServiceLocator {
  Future<void> initDependencies() async {
    await _initCore();
    _initAuth();
    _initProfile();
    _initCourses();
  }

  Future<void> _initCore() async {
    await _initStorage();
    _initDio();
  }

  /// =============================
  /// AUTH
  /// =============================
  void _initAuth() {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(networkService: sl(), preferencesStorage: sl()),
    );
    sl.registerLazySingleton(() => LoginUseCase(sl()));
    sl.registerLazySingleton(() => LogoutUseCase(sl()));
    sl.registerLazySingleton(() => GetWhatsappRegisterUrlUseCase(sl()));
    sl.registerFactory(() => LoginCubit(sl()));
    sl.registerFactory(() => LogoutCubit(sl()));
    sl.registerFactory(
      () => WhatsappRegisterCubit(getWhatsappRegisterUrlUseCase: sl()),
    );
  }

  /// =============================
  /// PROFILE
  /// =============================
  void _initProfile() {
    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        networkService: sl(),
        preferencesStorage: sl(),
        cacheService: sl(),
      ),
    );
    sl.registerLazySingleton(() => GetAccountInfoUseCase(sl()));
    sl.registerLazySingleton(() => UploadProfilePictureUseCase(sl()));
    sl.registerLazySingleton(() => UpdatePersonalProfileUseCase(sl()));
    sl.registerLazySingleton(() => GetMyCoursesUseCase(sl()));
    sl.registerLazySingleton(() => SubmitContactUsUseCase(sl()));
    sl.registerFactory(() => ProfileCubit(sl()));
    sl.registerFactory(() => EditProfileCubit(sl(), sl()));
    sl.registerFactory(() => MyCoursesCubit(sl()));
    sl.registerFactory(() => ContactUsCubit(submitContactUsUseCase: sl()));
  }

  /// =============================
  /// COURSES
  /// =============================
  void _initCourses() {
    sl.registerLazySingleton<CoursesRepository>(
      () => CoursesRepositoryImpl(networkService: sl(), cacheService: sl()),
    );
    sl.registerLazySingleton(() => GetClassesUseCase(sl()));
    sl.registerLazySingleton(() => GetCoursesUseCase(sl()));
    sl.registerLazySingleton(() => GetCourseDetailsUseCase(sl()));
    sl.registerLazySingleton(() => GetCourseCurriculumUseCase(sl()));
    sl.registerLazySingleton(() => RequestCourseUseCase(sl()));
    sl.registerLazySingleton(() => RequestChapterUseCase(sl()));
    sl.registerLazySingleton(() => GetCourseAssignmentsUseCase(sl()));
    sl.registerLazySingleton(() => GetAssignmentDetailsUseCase(sl()));
    sl.registerLazySingleton(() => SubmitAssignmentUseCase(sl()));
    sl.registerLazySingleton(() => GetAssignmentSubmissionsUseCase(sl()));
    sl.registerLazySingleton(() => GetCourseQuizzesUseCase(sl()));
    sl.registerLazySingleton(() => GetQuizDetailsUseCase(sl()));
    sl.registerLazySingleton(() => GetQuizQuestionsUseCase(sl()));
    sl.registerLazySingleton(() => StartQuizAttemptUseCase(sl()));
    sl.registerLazySingleton(() => SubmitAnswerUseCase(sl()));
    sl.registerLazySingleton(() => SubmitQuizUseCase(sl()));
    sl.registerLazySingleton(() => GetQuizResultUseCase(sl()));
    sl.registerLazySingleton(() => GetLiveSessionsUseCase(sl()));

    sl.registerFactory(() => ClassesCubit(sl()));
    sl.registerFactory(() => CoursesListCubit(sl()));
    sl.registerFactory(() => CourseDetailsCubit(sl()));
    sl.registerFactory(() => ChapterVideosCubit(repository: sl()));
    sl.registerFactory(() => CompleteVideoCubit(repository: sl()));
    sl.registerFactory(() => CompleteLessonCubit(repository: sl()));
    sl.registerFactory(() => RequestEnrollmentCubit(sl(), sl()));
    sl.registerFactory(
      () => CourseExamsCubit(
        getCourseAssignmentsUseCase: sl(),
        getAssignmentSubmissionsUseCase: sl(),
        getCourseQuizzesUseCase: sl(),
        getQuizResultUseCase: sl(),
      ),
    );
    sl.registerFactory(() => SubmitAssignmentCubit(sl(), sl()));
    sl.registerFactory(
      () => QuizCubit(
        startQuizAttemptUseCase: sl(),
        getQuizQuestionsUseCase: sl(),
        submitAnswerUseCase: sl(),
        submitQuizUseCase: sl(),
      ),
    );
    sl.registerFactory(
      () => CourseLiveSessionsCubit(getLiveSessionsUseCase: sl()),
    );
    sl.registerLazySingleton(() => GetCourseResourcesUseCase(sl()));
    sl.registerFactory(
      () => CourseResourcesCubit(getCourseResourcesUseCase: sl()),
    );
    sl.registerLazySingleton(() => GetCourseReviewsUseCase(sl()));
    sl.registerLazySingleton(() => AddCourseReviewUseCase(sl()));
    sl.registerLazySingleton(() => DownloadResourceUseCase(sl()));
    sl.registerFactory(() => CourseReviewsCubit(sl()));
    sl.registerFactory(() => AddCourseReviewCubit(sl()));
    sl.registerFactory(() => DownloadResourceCubit(downloadResourceUseCase: sl()));
  }

  /// =============================
  /// STORAGE & SERVICES
  /// =============================
  Future<void> _initStorage() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton(() => sharedPreferences);
    sl.registerLazySingleton(() => PreferencesStorage(sl()));
    sl.registerLazySingleton<CacheService>(
      () => HiveStorage(Hive.box(HiveBoxes.cacheBox)),
    );
  }

  /// =============================
  /// NETWORK
  /// =============================
  void _initDio() {
    sl.registerLazySingleton(() => Dio());
    sl.registerLazySingleton(() => NetworkService(sl()));
  }
}

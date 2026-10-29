import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/core/network/endpoints.dart';
import 'package:pythagoras/core/network/network_service.dart';
import 'package:pythagoras/core/cache/hive_storage.dart';
import 'package:pythagoras/core/enums/app_enums.dart';
import 'package:pythagoras/features/courses/data/models/student_class_model.dart';
import 'package:pythagoras/features/courses/data/models/course_model.dart';
import 'package:pythagoras/features/courses/data/models/course_detail_model.dart';
import 'package:pythagoras/features/courses/data/models/course_assignment_model.dart';
import 'package:pythagoras/features/courses/data/models/assignment_submission_model.dart';
import 'package:pythagoras/features/courses/data/models/course_quiz_model.dart';
import 'package:pythagoras/features/courses/data/models/quiz_question_model.dart';
import 'package:pythagoras/features/courses/data/models/quiz_attempt_model.dart';
import 'package:pythagoras/features/courses/data/models/answer_submitted_model.dart';
import 'package:pythagoras/features/courses/data/models/quiz_result_model.dart';
import 'package:pythagoras/features/courses/data/models/live_session_model.dart';
import 'package:pythagoras/features/courses/data/models/course_lesson_model.dart';
import 'package:pythagoras/core/constants/strings.dart';
import 'package:pythagoras/core/services/native_download_service.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';
import 'package:pythagoras/features/courses/domain/entities/course.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:pythagoras/features/courses/domain/entities/assignment_submission.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_question.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_attempt.dart';
import 'package:pythagoras/features/courses/domain/entities/answer_submitted.dart';
import 'package:pythagoras/features/courses/domain/entities/quiz_result.dart';
import 'package:pythagoras/features/courses/domain/entities/live_session.dart';
import 'package:pythagoras/features/courses/domain/entities/enrollment_result.dart';
import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';
import 'package:pythagoras/features/courses/data/models/course_resource_model.dart';
import 'package:pythagoras/features/courses/domain/entities/course_review.dart';
import 'package:pythagoras/features/courses/domain/entities/course_reviews_data.dart';
import 'package:pythagoras/features/courses/data/models/course_review_model.dart';
import 'package:pythagoras/features/courses/data/models/course_reviews_data_model.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';
import 'package:pythagoras/features/courses/domain/entities/apple_purchase_verification_result.dart';

class CoursesRepositoryImpl implements CoursesRepository {
  final NetworkService networkService;
  final CacheService cacheService;

  CoursesRepositoryImpl({
    required this.networkService,
    required this.cacheService,
  });

  @override
  Future<Either<Failure, List<StudentClass>>> getClasses({
    bool fromCache = false,
  }) async {
    try {
      final cacheKey = PreferencesKeys.cachedClasses.name;

      if (fromCache) {
        final cachedString = cacheService.getString(cacheKey);
        if (cachedString != null && cachedString.isNotEmpty) {
          final List<dynamic> dataList = json.decode(cachedString);
          final classes = dataList
              .map((e) => StudentClassModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return Right(classes);
        } else {
          return Left(Failure('No cached data'));
        }
      }

      final response = await networkService.getData(
        endPoint: EndPoints.classes,
      );

      return response.fold((failure) => Left(failure), (data) {
        if (data != null && data['success'] == true) {
          final List<dynamic> dataList = data['data'] ?? [];

          cacheService.saveString(cacheKey, json.encode(dataList));

          final classes = dataList
              .map((e) => StudentClassModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return Right(classes);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في جلب قائمة الصفوف'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Course>>> getCourses({
    int? classId,
    int? semester,
    bool fromCache = false,
  }) async {
    try {
      final cacheKey =
          '${PreferencesKeys.cachedCourses.name}_${classId ?? 'all'}_${semester ?? 'all'}';

      if (fromCache) {
        final cachedString = cacheService.getString(cacheKey);
        if (cachedString != null && cachedString.isNotEmpty) {
          final List<dynamic> dataList = json.decode(cachedString);
          final courses = dataList
              .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return Right(courses);
        } else {
          return Left(Failure('No cached data'));
        }
      }

      final Map<String, dynamic> queryParameters = {};
      if (classId != null) queryParameters['class_id'] = classId;
      if (semester != null) queryParameters['semester'] = semester;

      final response = await networkService.getData(
        endPoint: EndPoints.courses,
        queryParameters: queryParameters,
      );

      return response.fold((failure) => Left(failure), (data) async {
        if (data != null && data['success'] == true) {
          final List<dynamic> dataList = data['data'] ?? [];

          await cacheService.saveString(cacheKey, json.encode(dataList));

          final courses = dataList
              .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return Right(courses);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في جلب قائمة الدورات'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseDetail>> getCourseDetails(
    int courseId, {
    bool fromCache = false,
  }) async {
    try {
      final cacheKey = '${PreferencesKeys.cachedCourseDetails.name}_$courseId';

      if (fromCache) {
        final cachedString = cacheService.getString(cacheKey);
        if (cachedString != null && cachedString.isNotEmpty) {
          final Map<String, dynamic> dataMap = json.decode(cachedString);
          final courseDetail = CourseDetailModel.fromJson(dataMap);
          return Right(courseDetail);
        } else {
          return Left(Failure('No cached data'));
        }
      }

      final response = await networkService.getData(
        endPoint: '${EndPoints.courses}/$courseId',
      );

      return response.fold((failure) => Left(failure), (data) async {
        if (data != null && data['success'] == true) {
          final courseData = data['data'] as Map<String, dynamic>;

          await cacheService.saveString(cacheKey, json.encode(courseData));

          final courseDetail = CourseDetailModel.fromJson(courseData);
          return Right(courseDetail);
        } else {
          return Left(
            Failure(
              data?['message']?.toString() ?? 'فشل في جلب تفاصيل الدورات',
            ),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseDetail>> getCourseCurriculum(
    int courseId, {
    bool fromCache = false,
  }) async {
    try {
      final cacheKey =
          '${PreferencesKeys.cachedCourseDetails.name}_curriculum_$courseId';

      if (fromCache) {
        final cachedString = cacheService.getString(cacheKey);
        if (cachedString != null && cachedString.isNotEmpty) {
          final Map<String, dynamic> courseData = json.decode(cachedString);
          final courseDetail = CourseDetailModel.fromJson(courseData);
          return Right(courseDetail);
        } else {
          return Left(Failure('No cached data'));
        }
      }

      final response = await networkService.getData(
        endPoint: EndPoints.courseCurriculum(courseId),
      );

      return response.fold((failure) => Left(failure), (data) async {
        if (data != null && data['success'] == true) {
          // curriculum API wraps properties in data['course']
          final courseData = data['data']['course'] as Map<String, dynamic>;
          courseData['instructor'] = data['data']['instructor'];
          courseData['chapters'] = data['data']['chapters'];

          await cacheService.saveString(cacheKey, json.encode(courseData));

          final courseDetail = CourseDetailModel.fromJson(courseData);
          return Right(courseDetail);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في جلب محتوى الدورة'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> requestCourse(int courseId) async {
    try {
      final response = await networkService.postData(
        endPoint: EndPoints.requestCourse,
        data: {'courseId': courseId},
      );

      return response.fold((failure) => Left(failure), (data) {
        if (data != null && data['whatsappUrl'] != null) {
          return Right(data['whatsappUrl'] as String);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في طلب الدورة'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> requestChapter(int chapterId) async {
    try {
      final response = await networkService.postData(
        endPoint: EndPoints.requestChapter,
        data: {'chapterId': chapterId},
      );

      return response.fold((failure) => Left(failure), (data) {
        if (data != null && data['whatsappUrl'] != null) {
          return Right(data['whatsappUrl'] as String);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في طلب الحصة'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // iOS-only: direct enrollment (no WhatsApp redirect)
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, String>> requestCourseDirect(int courseId) async {
    try {
      final response = await networkService.postData(
        endPoint: EndPoints.requestCourseDirect,
        data: {'courseId': courseId},
      );

      return response.fold((failure) => Left(failure), (data) {
        final message = data?['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return Right(message);
        } else {
          return Left(Failure('فشل في طلب الدورة'));
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> requestChapterDirect(int chapterId) async {
    try {
      final response = await networkService.postData(
        endPoint: EndPoints.requestChapterDirect,
        data: {'chapterId': chapterId},
      );

      return response.fold((failure) => Left(failure), (data) {
        final message = data?['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return Right(message);
        } else {
          return Left(Failure('فشل في طلب الحصة'));
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EnrollmentResult>> enrollCourse(int courseId) {
    return _enrollContent(
      endPoint: EndPoints.enrollCourse,
      idField: 'courseId',
      contentId: courseId,
      failureMessage: 'فشل في تسجيل الدورة',
    );
  }

  @override
  Future<Either<Failure, EnrollmentResult>> enrollChapter(int chapterId) {
    return _enrollContent(
      endPoint: EndPoints.enrollChapter,
      idField: 'chapterId',
      contentId: chapterId,
      failureMessage: 'فشل في تسجيل الفصل',
    );
  }

  @override
  Future<ApplePurchaseVerificationResult> verifyApplePurchase(
    String signedTransaction,
  ) async {
    try {
      final response = await networkService.postSensitiveData(
        endPoint: EndPoints.verifyApplePurchase,
        data: {'signedTransaction': signedTransaction},
      );
      if (response.isHttpResponse) {
        return ApplePurchaseVerificationResult.http(response.statusCode);
      }
      return ApplePurchaseVerificationResult.networkError(
        response.networkError ?? 'تعذر الاتصال بخدمة التحقق',
      );
    } catch (_) {
      return const ApplePurchaseVerificationResult.networkError(
        'تعذر الاتصال بخدمة التحقق',
      );
    }
  }

  Future<Either<Failure, EnrollmentResult>> _enrollContent({
    required String endPoint,
    required String idField,
    required int contentId,
    required String failureMessage,
  }) async {
    try {
      final response = await networkService.postData(
        endPoint: endPoint,
        data: {idField: contentId},
      );

      return response.fold((failure) => Left(failure), (data) {
        if (data is Map &&
            (data['enrolled'] == true || data['alreadyEnrolled'] == true)) {
          final message = data['message']?.toString();
          return Right(
            EnrollmentResult(
              message: message != null && message.isNotEmpty
                  ? message
                  : 'تم تأكيد تسجيل المحتوى',
              alreadyEnrolled: data['alreadyEnrolled'] == true,
            ),
          );
        }

        return Left(
          Failure(
            data is Map
                ? data['message']?.toString() ?? failureMessage
                : failureMessage,
          ),
        );
      });
    } catch (error) {
      return Left(Failure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseLesson>>> getChapterVideos(
    int chapterId, {
    bool fromCache = false,
  }) async {
    try {
      final cacheKey = '${PreferencesKeys.cachedChapterVideos.name}_$chapterId';

      if (fromCache) {
        final cachedString = cacheService.getString(cacheKey);
        if (cachedString != null && cachedString.isNotEmpty) {
          final List<dynamic> jsonList = json.decode(cachedString);
          final videos = jsonList
              .map((json) => CourseLessonModel.fromJson(json))
              .toList();
          return Right(videos);
        } else {
          return Left(Failure('No cached data'));
        }
      }

      final response = await networkService.getData(
        endPoint: EndPoints.chapterVideos(chapterId),
      );
      return response.fold((failure) => Left(failure), (data) async {
        if (data != null && data['success'] == true) {
          final List<dynamic> jsonList = data['data'] ?? [];

          await cacheService.saveString(cacheKey, json.encode(jsonList));

          final videos = jsonList
              .map((json) => CourseLessonModel.fromJson(json))
              .toList();
          return Right(videos);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في جلب الدروس'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> completeVideo(int videoId) async {
    try {
      final response = await networkService.postData(
        endPoint: EndPoints.completeVideo(videoId),
        data: {}, // no body needed
      );
      return response.fold((failure) => Left(failure), (data) {
        if (data != null && data['success'] == true) {
          return Right(
            data['message']?.toString() ??
                'تم وضع علامة على الفيديو بأنه مكتمل',
          );
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في اتمام الدرس'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> completeLesson(int lessonId) async {
    try {
      final response = await networkService.postData(
        endPoint: EndPoints.completeLesson(lessonId),
        data: {},
      );
      return response.fold((failure) => Left(failure), (data) {
        if (data != null && data['success'] == true) {
          return Right(data['message']?.toString() ?? 'تم اكتمال الدرس بنجاح');
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في اتمام الدرس'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseAssignment>>> getCourseAssignments(
    int courseId, {
    bool fromCache = false,
  }) async {
    try {
      final cacheKey =
          '${PreferencesKeys.cachedCourseAssignments.name}_$courseId';

      if (fromCache) {
        final cachedString = cacheService.getString(cacheKey);
        if (cachedString != null && cachedString.isNotEmpty) {
          final List<dynamic> dataList = json.decode(cachedString);
          final assignments = dataList
              .map(
                (e) =>
                    CourseAssignmentModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
          return Right(assignments);
        } else {
          return Left(Failure('No cached data'));
        }
      }

      final response = await networkService.getData(
        endPoint: EndPoints.courseAssignments(courseId),
      );
      return response.fold((failure) => Left(failure), (data) async {
        if (data != null && data['success'] == true) {
          final List<dynamic> dataList = data['data'] ?? [];

          await cacheService.saveString(cacheKey, json.encode(dataList));

          final assignments = dataList
              .map(
                (e) =>
                    CourseAssignmentModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
          return Right(assignments);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في جلب الواجبات'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseAssignment>> getAssignmentDetails(
    int assignmentId,
  ) async {
    try {
      final response = await networkService.getData(
        endPoint: EndPoints.assignmentDetails(assignmentId),
      );
      return response.fold((failure) => Left(failure), (data) {
        if (data != null && data['success'] == true) {
          final assignment = CourseAssignmentModel.fromJson(
            data['data'] as Map<String, dynamic>,
          );
          return Right(assignment);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في جلب تفاصيل الواجب'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssignmentSubmission>> submitAssignment({
    required int assignmentId,
    String? notes,
    String? filePath,
    String? fileName,
  }) async {
    try {
      final formData = FormData();
      if (notes != null && notes.isNotEmpty) {
        formData.fields.add(MapEntry('notes', notes));
      }
      if (filePath != null) {
        formData.files.add(
          MapEntry(
            'file',
            await MultipartFile.fromFile(
              filePath,
              filename: fileName ?? filePath.split('/').last,
            ),
          ),
        );
      }
      final response = await networkService.uploadFile(
        endPoint: EndPoints.submitAssignment(assignmentId),
        formData: formData,
      );
      return response.fold((failure) => Left(Failure(failure.message)), (data) {
        if (data != null && data['success'] == true) {
          final submission = AssignmentSubmissionModel.fromJson(
            data['data'] as Map<String, dynamic>,
          );
          return Right(submission);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في تسليم الواجب'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AssignmentSubmission>>> getAssignmentSubmissions(
    int assignmentId, {
    bool fromCache = false,
  }) async {
    try {
      final cacheKey =
          '${PreferencesKeys.cachedAssignmentSubmissions.name}_$assignmentId';

      if (fromCache) {
        final cachedString = cacheService.getString(cacheKey);
        if (cachedString != null && cachedString.isNotEmpty) {
          final List<dynamic> dataList = json.decode(cachedString);
          final submissions = dataList
              .map(
                (e) => AssignmentSubmissionModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();
          return Right(submissions);
        } else {
          return Left(Failure('No cached data'));
        }
      }

      final response = await networkService.getData(
        endPoint: EndPoints.assignmentSubmissions(assignmentId),
      );
      return response.fold((failure) => Left(failure), (data) async {
        if (data != null && data['success'] == true) {
          final List<dynamic> dataList = data['data'] ?? [];

          await cacheService.saveString(cacheKey, json.encode(dataList));

          final submissions = dataList
              .map(
                (e) => AssignmentSubmissionModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();
          return Right(submissions);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في جلب التسليمات'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseQuiz>>> getCourseQuizzes(
    int courseId, {
    bool fromCache = false,
  }) async {
    try {
      final cacheKey = '${PreferencesKeys.cachedCourseQuizzes.name}_$courseId';

      if (fromCache) {
        final cachedString = cacheService.getString(cacheKey);
        if (cachedString != null && cachedString.isNotEmpty) {
          final List<dynamic> dataList = json.decode(cachedString);
          final quizzes = dataList
              .map((e) => CourseQuizModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return Right(quizzes);
        } else {
          return Left(Failure('No cached data'));
        }
      }

      final response = await networkService.getData(
        endPoint: EndPoints.courseQuizzes(courseId),
      );
      return response.fold((failure) => Left(failure), (data) async {
        if (data != null && data['success'] == true) {
          final List<dynamic> dataList = data['data'] ?? [];

          await cacheService.saveString(cacheKey, json.encode(dataList));

          final quizzes = dataList
              .map((e) => CourseQuizModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return Right(quizzes);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في جلب الامتحانات'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseQuiz>> getQuizDetails(int quizId) async {
    try {
      final response = await networkService.getData(
        endPoint: EndPoints.quizDetails(quizId),
      );
      return response.fold((failure) => Left(failure), (data) {
        if (data != null && data['success'] == true) {
          final quiz = CourseQuizModel.fromJson(
            data['data'] as Map<String, dynamic>,
          );
          return Right(quiz);
        } else {
          return Left(
            Failure(
              data?['message']?.toString() ?? 'فشل في جلب تفاصيل الامتحان',
            ),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuizQuestion>>> getQuizQuestions(
    int quizId,
  ) async {
    try {
      final response = await networkService.getData(
        endPoint: EndPoints.quizQuestions(quizId),
      );
      return response.fold((failure) => Left(failure), (data) {
        if (data != null && data['success'] == true) {
          final List<dynamic> dataList = data['data'] ?? [];
          final questions = dataList
              .map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return Right(questions);
        } else {
          return Left(
            Failure(
              data?['message']?.toString() ?? 'فشل في جلب أسئلة الامتحان',
            ),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuizAttempt>> startQuizAttempt(int quizId) async {
    try {
      final response = await networkService.postData(
        endPoint: EndPoints.startQuizAttempt(quizId),
        data: {'quiz_id': quizId},
      );
      return response.fold((failure) => Left(failure), (data) {
        if (data != null && data['success'] == true) {
          final attempt = QuizAttemptModel.fromJson(
            data['data'] as Map<String, dynamic>,
          );
          return Right(attempt);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في بدء الامتحان'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnswerSubmitted>> submitAnswer({
    required int quizId,
    required int quizAttemptId,
    required int questionId,
    int? optionId,
    dynamic selectedAnswer,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'quiz_attempt_id': quizAttemptId,
        'question_id': questionId,
      };
      if (optionId != null) body['option_id'] = optionId;
      if (selectedAnswer != null) body['selected_answer'] = selectedAnswer;

      final response = await networkService.postData(
        endPoint: EndPoints.submitAnswer(quizId),
        data: body,
      );
      return response.fold((failure) => Left(failure), (data) {
        if (data != null && (data['success'] == true || data['data'] != null)) {
          final dataMap = data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : (data is Map<String, dynamic> ? data : <String, dynamic>{});
          final answer = AnswerSubmittedModel.fromJson(dataMap);
          return Right(answer);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في تقديم الإجابة'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuizResult>> submitQuiz({
    required int quizId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await networkService.postData(
        endPoint: EndPoints.submitQuiz(quizId),
        data: {'quiz_id': quizId, 'answers': answers},
      );
      return response.fold((failure) => Left(failure), (data) {
        if (data != null &&
            (data['success'] == true ||
                data['summary'] != null ||
                data['data'] != null)) {
          final dataMap = data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : (data is Map<String, dynamic> ? data : <String, dynamic>{});
          final result = QuizResultModel.fromJson(dataMap);
          // Cache the result so getQuizResult can return it without a separate API call
          final cacheKey = '${PreferencesKeys.cachedQuizResult.name}_$quizId';
          cacheService.saveString(cacheKey, json.encode(dataMap));
          return Right(result);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في إنهاء الامتحان'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuizResult>> getQuizResult(
    int quizId, {
    bool fromCache = false,
  }) async {
    // Results are cached by submitQuiz after a successful submission.
    // We only read from cache — the api/quizzes/{id}/result endpoint is not used.
    try {
      final cacheKey = '${PreferencesKeys.cachedQuizResult.name}_$quizId';
      final cachedString = cacheService.getString(cacheKey);

      if (cachedString != null && cachedString.isNotEmpty) {
        final dataMap = json.decode(cachedString);
        final result = QuizResultModel.fromJson(
          dataMap as Map<String, dynamic>,
        );
        return Right(result);
      }

      return Left(Failure('No cached data'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LiveSession>>> getLiveSessions(
    int courseId, {
    bool fromCache = false,
  }) async {
    try {
      final cacheKey = '${PreferencesKeys.cachedLiveSessions.name}_$courseId';

      if (fromCache) {
        final cachedString = cacheService.getString(cacheKey);
        if (cachedString != null && cachedString.isNotEmpty) {
          final List<dynamic> dataList = json.decode(cachedString);
          final sessions = dataList
              .map((e) => LiveSessionModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return Right(sessions);
        } else {
          return Left(Failure('No cached data'));
        }
      }

      final response = await networkService.getData(
        endPoint: EndPoints.courseLiveSessions(courseId),
      );
      return response.fold((failure) => Left(failure), (data) async {
        if (data != null && data['data'] != null) {
          final List<dynamic> dataList = data['data'] ?? [];

          await cacheService.saveString(cacheKey, json.encode(dataList));

          final sessions = dataList
              .map((e) => LiveSessionModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return Right(sessions);
        } else {
          return Left(
            Failure(
              data?['message']?.toString() ?? 'فشل في جلب الحصص المباشرة',
            ),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseResource>>> getCourseResources(
    int courseId, {
    bool fromCache = false,
  }) async {
    try {
      final cacheKey =
          '${PreferencesKeys.cachedCourseResources.name}_$courseId';

      if (fromCache) {
        final cachedString = cacheService.getString(cacheKey);
        if (cachedString != null && cachedString.isNotEmpty) {
          final List<dynamic> dataList = json.decode(cachedString);
          final resources = dataList
              .map(
                (e) => CourseResourceModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
          return Right(resources);
        } else {
          return Left(Failure('No cached data'));
        }
      }

      final response = await networkService.getData(
        endPoint: EndPoints.courseResources(courseId),
      );
      return response.fold((failure) => Left(failure), (data) async {
        if (data != null && data['success'] == true) {
          final List<dynamic> dataList = data['data'] ?? [];

          await cacheService.saveString(cacheKey, json.encode(dataList));

          final resources = dataList
              .map(
                (e) => CourseResourceModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
          return Right(resources);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في جلب الملازم'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseReviewsData>> getCourseReviews(
    int courseId, {
    bool fromCache = false,
  }) async {
    try {
      final cacheKey = '${PreferencesKeys.cachedCourseReviews.name}_$courseId';

      if (fromCache) {
        final cachedString = cacheService.getString(cacheKey);
        if (cachedString != null && cachedString.isNotEmpty) {
          final dataMap = json.decode(cachedString);
          final reviewsData = CourseReviewsDataModel.fromJson(
            dataMap as Map<String, dynamic>,
          );
          return Right(reviewsData);
        } else {
          return Left(Failure('No cached data'));
        }
      }

      final response = await networkService.getData(
        endPoint: EndPoints.courseReviews(courseId),
      );
      return response.fold((failure) => Left(failure), (data) async {
        if (data != null && data['success'] == true && data['data'] != null) {
          await cacheService.saveString(cacheKey, json.encode(data['data']));
          final reviewsData = CourseReviewsDataModel.fromJson(
            data['data'] as Map<String, dynamic>,
          );
          return Right(reviewsData);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في جلب التقييمات'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseReview>> addCourseReview({
    required int courseId,
    required double rating,
    required String comment,
  }) async {
    try {
      final response = await networkService.postData(
        endPoint: EndPoints.courseReviews(courseId),
        data: {'rating': rating, 'comment': comment},
      );
      return response.fold((failure) => Left(failure), (data) {
        if (data != null && data['success'] == true && data['data'] != null) {
          final review = CourseReviewModel.fromJson(
            data['data'] as Map<String, dynamic>,
          );
          return Right(review);
        } else {
          return Left(
            Failure(data?['message']?.toString() ?? 'فشل في إضافة التقييم'),
          );
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> downloadResourceNative({
    required int resourceId,
    required String title,
    required String fileName,
  }) async {
    try {
      final url =
          '${AppStrings.baseUrl}${EndPoints.downloadResource(resourceId)}';
      final success = await NativeDownloadService().enqueueDownload(
        url: url,
        title: title,
        fileName: fileName,
      );
      if (success) {
        return const Right(null);
      } else {
        return const Left(Failure('فشل في بدء التحميل'));
      }
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}

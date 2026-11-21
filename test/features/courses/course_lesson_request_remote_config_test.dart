import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/core/services/remote_config_service.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_chapter_direct_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_chapter_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_course_direct_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/request_course_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/direct_request/direct_request_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/request_enrollment/request_enrollment_cubit.dart';

class _RemoteConfigService extends RemoteConfigService {
  final StreamController<bool> iapUpdates = StreamController<bool>.broadcast(
    sync: true,
  );
  final StreamController<bool> requestUpdates =
      StreamController<bool>.broadcast(sync: true);
  final StreamController<bool> deleteAccountUpdates =
      StreamController<bool>.broadcast(sync: true);
  bool iapEnabled = false;
  bool requestsEnabled = true;
  bool deleteAccountFlagEnabled = true;

  _RemoteConfigService() : super(isIos: false);

  @override
  bool get iosIapEnabled => iapEnabled;

  @override
  Stream<bool> get iosIapEnabledChanges => iapUpdates.stream;

  @override
  bool get courseLessonRequestsEnabled => requestsEnabled;

  @override
  Stream<bool> get courseLessonRequestsEnabledChanges => requestUpdates.stream;

  @override
  bool get deleteAccountEnabled => deleteAccountFlagEnabled;

  @override
  Stream<bool> get deleteAccountEnabledChanges => deleteAccountUpdates.stream;

  @override
  Future<void> initialize() async {}

  void setIapEnabled(bool value) {
    iapEnabled = value;
    iapUpdates.add(value);
  }

  void setRequestsEnabled(bool value) {
    requestsEnabled = value;
    requestUpdates.add(value);
  }

  void setDeleteAccountEnabled(bool value) {
    deleteAccountFlagEnabled = value;
    deleteAccountUpdates.add(value);
  }
}

class _RequestRepository implements CoursesRepository {
  int? requestedCourseId;
  int? requestedChapterId;
  int? directlyRequestedCourseId;
  int? directlyRequestedChapterId;

  @override
  Future<Either<Failure, String>> requestCourse(int courseId) async {
    requestedCourseId = courseId;
    return const Right('course request');
  }

  @override
  Future<Either<Failure, String>> requestChapter(int chapterId) async {
    requestedChapterId = chapterId;
    return const Right('chapter request');
  }

  @override
  Future<Either<Failure, String>> requestCourseDirect(int courseId) async {
    directlyRequestedCourseId = courseId;
    return const Right('direct course request');
  }

  @override
  Future<Either<Failure, String>> requestChapterDirect(int chapterId) async {
    directlyRequestedChapterId = chapterId;
    return const Right('direct chapter request');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'request flag defaults enabled on non-iOS without fetching Firebase',
    () {
      expect(
        RemoteConfigService(isIos: false).courseLessonRequestsEnabled,
        isTrue,
      );
    },
  );

  test(
    'delete account flag false is propagated to Remote Config state',
    () async {
      final service = _RemoteConfigService();
      final cubit = RemoteConfigCubit(remoteConfigService: service);

      await cubit.load();
      expect(cubit.state.deleteAccountEnabled, isTrue);

      service.setDeleteAccountEnabled(false);
      expect(cubit.state.deleteAccountEnabled, isFalse);

      await cubit.close();
      await service.deleteAccountUpdates.close();
    },
  );

  test(
    'Remote Config streams request changes independently of Apple IAP',
    () async {
      final service = _RemoteConfigService();
      final cubit = RemoteConfigCubit(remoteConfigService: service);

      await cubit.load();
      expect(cubit.state.iosIapEnabled, isFalse);
      expect(cubit.state.courseLessonRequestsEnabled, isTrue);

      service.setRequestsEnabled(false);
      expect(cubit.state.courseLessonRequestsEnabled, isFalse);
      expect(cubit.state.iosIapEnabled, isFalse);

      service.setIapEnabled(true);
      expect(cubit.state.iosIapEnabled, isTrue);
      expect(cubit.state.courseLessonRequestsEnabled, isFalse);

      await cubit.close();
      await service.iapUpdates.close();
      await service.requestUpdates.close();
      await service.deleteAccountUpdates.close();
    },
  );

  test(
    'disabled request flag blocks direct and WhatsApp course/chapter calls',
    () async {
      final directRepository = _RequestRepository();
      final directCubit = DirectRequestCubit(
        requestCourseDirectUseCase: RequestCourseDirectUseCase(
          directRepository,
        ),
        requestChapterDirectUseCase: RequestChapterDirectUseCase(
          directRepository,
        ),
        isCourseLessonRequestsEnabled: () => false,
      );
      final requestRepository = _RequestRepository();
      final requestCubit = RequestEnrollmentCubit(
        RequestCourseUseCase(requestRepository),
        RequestChapterUseCase(requestRepository),
        isCourseLessonRequestsEnabled: () => false,
      );

      await directCubit.requestCourse(21);
      await directCubit.requestChapter(245);
      await requestCubit.requestCourse(21);
      await requestCubit.requestChapter(245);

      expect(directRepository.directlyRequestedCourseId, isNull);
      expect(directRepository.directlyRequestedChapterId, isNull);
      expect(requestRepository.requestedCourseId, isNull);
      expect(requestRepository.requestedChapterId, isNull);

      await directCubit.close();
      await requestCubit.close();
    },
  );

  test('enabled request flag permits direct and WhatsApp requests', () async {
    final directRepository = _RequestRepository();
    final directCubit = DirectRequestCubit(
      requestCourseDirectUseCase: RequestCourseDirectUseCase(directRepository),
      requestChapterDirectUseCase: RequestChapterDirectUseCase(
        directRepository,
      ),
      isCourseLessonRequestsEnabled: () => true,
    );
    final requestRepository = _RequestRepository();
    final requestCubit = RequestEnrollmentCubit(
      RequestCourseUseCase(requestRepository),
      RequestChapterUseCase(requestRepository),
      isCourseLessonRequestsEnabled: () => true,
    );

    await directCubit.requestCourse(21);
    await directCubit.requestChapter(245);
    await requestCubit.requestCourse(31);
    await requestCubit.requestChapter(250);

    expect(directRepository.directlyRequestedCourseId, 21);
    expect(directRepository.directlyRequestedChapterId, 245);
    expect(requestRepository.requestedCourseId, 31);
    expect(requestRepository.requestedChapterId, 250);

    await directCubit.close();
    await requestCubit.close();
  });
}

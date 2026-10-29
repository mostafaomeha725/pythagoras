import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/core/cache/hive_storage.dart';
import 'package:pythagoras/core/cache/preferences_storage.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/core/network/endpoints.dart';
import 'package:pythagoras/core/network/network_service.dart';
import 'package:pythagoras/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNetworkService extends NetworkService {
  _FakeNetworkService() : super(Dio());

  String? requestedEndpoint;
  Map<String, dynamic>? requestedBody;
  Either<Failure, dynamic> response = const Right(<String, dynamic>{});
  String? sensitiveEndpoint;
  Map<String, dynamic>? sensitiveBody;
  SensitiveHttpResult sensitiveResponse = const SensitiveHttpResult.http(200);

  @override
  Future<Either<Failure, dynamic>> postData({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    String? token,
    bool isRaw = true,
  }) async {
    requestedEndpoint = endPoint;
    requestedBody = data;
    return response;
  }

  @override
  Future<SensitiveHttpResult> postSensitiveData({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool isRaw = true,
  }) async {
    sensitiveEndpoint = endPoint;
    sensitiveBody = data;
    return sensitiveResponse;
  }
}

class _FakeCacheService implements CacheService {
  @override
  String? getString(String key) => null;

  @override
  Future<void> saveString(String key, String value) async {}

  @override
  Future<void> delete(String key) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  late _FakeNetworkService networkService;
  late CoursesRepositoryImpl repository;

  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    sl.registerSingleton<PreferencesStorage>(PreferencesStorage(preferences));
    networkService = _FakeNetworkService();
    repository = CoursesRepositoryImpl(
      networkService: networkService,
      cacheService: _FakeCacheService(),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  test('course enrollment sends the supplied course ID', () async {
    networkService.response = const Right({
      'courseId': 31,
      'enrolled': true,
      'alreadyEnrolled': false,
      'message': 'Course enrolled',
    });

    final result = await repository.enrollCourse(31);

    expect(networkService.requestedEndpoint, EndPoints.enrollCourse);
    expect(networkService.requestedBody, {'courseId': 31});
    expect(result.isRight(), isTrue);
    expect(
      result.fold((_) => null, (value) => value)?.alreadyEnrolled,
      isFalse,
    );
  });

  test(
    'already enrolled chapter is treated as an idempotent success',
    () async {
      networkService.response = const Right({
        'chapterId': 250,
        'enrolled': false,
        'alreadyEnrolled': true,
        'message': 'Chapter already enrolled',
      });

      final result = await repository.enrollChapter(250);

      expect(networkService.requestedEndpoint, EndPoints.enrollChapter);
      expect(networkService.requestedBody, {'chapterId': 250});
      expect(result.isRight(), isTrue);
      expect(
        result.fold((_) => null, (value) => value)?.alreadyEnrolled,
        isTrue,
      );
    },
  );

  test('HTTP success without an enrollment flag is not accepted', () async {
    networkService.response = const Right({'message': 'Request accepted'});

    final result = await repository.enrollCourse(31);

    expect(result.isLeft(), isTrue);
  });

  test('network failure remains a failure and can be retried', () async {
    networkService.response = Left(Failure('No internet connection'));

    final firstAttempt = await repository.enrollChapter(250);
    expect(firstAttempt.isLeft(), isTrue);

    networkService.response = const Right({
      'chapterId': 250,
      'enrolled': true,
      'alreadyEnrolled': false,
    });
    final retry = await repository.enrollChapter(250);

    expect(retry.isRight(), isTrue);
    expect(networkService.requestedBody, {'chapterId': 250});
  });

  test('Apple verification receives the unchanged StoreKit value', () async {
    const signedTransaction = 'actual-storekit-proof';
    networkService.sensitiveResponse = const SensitiveHttpResult.http(200);

    final result = await repository.verifyApplePurchase(signedTransaction);

    expect(networkService.sensitiveEndpoint, EndPoints.verifyApplePurchase);
    expect(networkService.sensitiveBody, {
      'signedTransaction': signedTransaction,
    });
    expect(result.statusCode, 200);
    expect(result.isVerified, isTrue);
  });

  test('Apple verification 404 and 422 responses remain failures', () async {
    for (final statusCode in [404, 422]) {
      networkService.sensitiveResponse = SensitiveHttpResult.http(statusCode);

      final result = await repository.verifyApplePurchase('actual-proof');

      expect(result.statusCode, statusCode);
      expect(result.isVerified, statusCode == 200);
      expect(networkService.requestedEndpoint, isNull);
    }
  });
}

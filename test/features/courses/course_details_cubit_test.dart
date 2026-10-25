import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/courses/data/models/course_detail_model.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_course_curriculum_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/course_details/course_details_state.dart';

class FakeCoursesRepository implements CoursesRepository {
  Future<Either<Failure, CourseDetail>> Function(bool fromCache)? handler;

  @override
  Future<Either<Failure, CourseDetail>> getCourseCurriculum(
    int courseId, {
    bool fromCache = false,
  }) {
    return handler!(fromCache);
  }

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

const course = CourseDetail(
  id: 21,
  title: 'Course 21',
  level: 'Secondary',
  className: 'Class 1',
  isEnrolled: false,
  price: '100',
  finalPrice: 100,
  currencyLabel: 'EGP',
  studentsCount: 0,
  isSaved: false,
  rating: 0,
  category: 'Math',
  chapters: [],
);

void main() {
  late FakeCoursesRepository repository;
  late CourseDetailsCubit cubit;

  setUp(() {
    repository = FakeCoursesRepository();
    cubit = CourseDetailsCubit(GetCourseCurriculumUseCase(repository));
  });

  tearDown(() => cubit.close());

  test('fetches current course status directly from the API', () async {
    final cacheModes = <bool>[];
    repository.handler = (fromCache) {
      cacheModes.add(fromCache);
      return Future.value(const Right(course));
    };

    expect(cubit.state, isA<CourseDetailsInitial>());
    final request = cubit.fetchCourseDetails(21);

    expect(cubit.state, isA<CourseDetailsLoading>());
    await request;
    expect(cubit.state, isA<CourseDetailsLoaded>());
    expect(cacheModes, [false]);
  });

  test(
    'never displays cached enrollment before the current API response',
    () async {
      repository.handler = (fromCache) async {
        if (fromCache) return const Right(course);
        return Right(course.copyWith(title: 'Current account course'));
      };

      final states = <CourseDetailsState>[];
      final subscription = cubit.stream.listen(states.add);
      await cubit.fetchCourseDetails(21);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(states, hasLength(2));
      expect(states[0], isA<CourseDetailsLoading>());
      expect(
        (states[1] as CourseDetailsLoaded).courseDetail.title,
        'Current account course',
      );
    },
  );

  test(
    'a second account refresh uses its own API response, never cached status',
    () async {
      final accountResponses = [
        course.copyWith(isEnrolled: true, requestStatus: 'accepted'),
        course.copyWith(isEnrolled: false, requestStatus: 'not_requested'),
      ];
      final cacheModes = <bool>[];
      repository.handler = (fromCache) {
        cacheModes.add(fromCache);
        return Future.value(Right(accountResponses.removeAt(0)));
      };

      await cubit.fetchCourseDetails(21);
      expect(
        (cubit.state as CourseDetailsLoaded).courseDetail.isEnrolled,
        isTrue,
      );

      await cubit.fetchCourseDetails(21);
      final secondAccountCourse =
          (cubit.state as CourseDetailsLoaded).courseDetail;
      expect(secondAccountCourse.isEnrolled, isFalse);
      expect(secondAccountCourse.requestStatus, 'not_requested');
      expect(cacheModes, [false, false]);
    },
  );

  test(
    'course model normalizes request_status and handles unknown values safely',
    () {
      CourseDetailModel parseStatus(String requestStatus) =>
          CourseDetailModel.fromJson({
            'id': 21,
            'title': 'Course 21',
            'request_status': requestStatus,
            'chapters': const [],
          });

      final accepted = parseStatus(' accepted ');
      expect(accepted.requestStatus, 'accepted');
      expect(accepted.isEnrolled, isTrue);

      final pending = parseStatus('pending ');
      expect(pending.requestStatus, 'pending');
      expect(pending.isEnrolled, isFalse);

      final unknown = parseStatus('unexpected ');
      expect(unknown.requestStatus, 'unexpected');
      expect(unknown.isEnrolled, isFalse);
    },
  );

  test(
    'emits API Error instead of falling back to cached enrollment',
    () async {
      repository.handler = (fromCache) =>
          Future.value(const Left(Failure('remote failed')));

      await cubit.fetchCourseDetails(21);

      expect(cubit.state, isA<CourseDetailsError>());
      expect((cubit.state as CourseDetailsError).message, 'remote failed');
    },
  );

  test('emits Error when the current API request throws', () async {
    repository.handler = (fromCache) {
      return Future<Either<Failure, CourseDetail>>.error(
        StateError('API exception'),
      );
    };

    await cubit.fetchCourseDetails(21);

    expect(cubit.state, isA<CourseDetailsError>());
    expect(
      (cubit.state as CourseDetailsError).message,
      contains('API exception'),
    );
  });
}

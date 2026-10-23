import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/core/error/failure.dart';
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

  test('starts in Initial and emits Loading before cache completes', () async {
    final cache = Completer<Either<Failure, CourseDetail>>();
    repository.handler = (fromCache) =>
        fromCache ? cache.future : Future.value(const Right(course));

    expect(cubit.state, isA<CourseDetailsInitial>());
    final request = cubit.fetchCourseDetails(21);

    expect(cubit.state, isA<CourseDetailsLoading>());
    cache.complete(const Left(Failure('No cached data')));
    await request;
    expect(cubit.state, isA<CourseDetailsLoaded>());
  });

  test('emits cached Loaded state, then remote Loaded state', () async {
    repository.handler = (fromCache) => Future.value(
      fromCache
          ? const Right(course)
          : Right(course.copyWith(title: 'Remote course')),
    );

    final states = <CourseDetailsState>[];
    final subscription = cubit.stream.listen(states.add);
    await cubit.fetchCourseDetails(21);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(states, hasLength(3));
    expect(states[0], isA<CourseDetailsLoading>());
    expect((states[1] as CourseDetailsLoaded).courseDetail.title, 'Course 21');
    expect(
      (states[2] as CourseDetailsLoaded).courseDetail.title,
      'Remote course',
    );
  });

  test('emits Error when cache and remote both fail', () async {
    repository.handler = (fromCache) => Future.value(
      Left(Failure(fromCache ? 'cache failed' : 'remote failed')),
    );

    await cubit.fetchCourseDetails(21);

    expect(cubit.state, isA<CourseDetailsError>());
    expect((cubit.state as CourseDetailsError).message, 'remote failed');
  });

  test('emits Error when reading cache throws', () async {
    repository.handler = (fromCache) {
      if (fromCache) {
        return Future<Either<Failure, CourseDetail>>.error(
          StateError('cache exception'),
        );
      }
      return Future.value(const Right(course));
    };

    await cubit.fetchCourseDetails(21);

    expect(cubit.state, isA<CourseDetailsError>());
    expect(
      (cubit.state as CourseDetailsError).message,
      contains('cache exception'),
    );
  });
}

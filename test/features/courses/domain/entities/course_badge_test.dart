import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/features/courses/data/models/course_model.dart';
import 'package:pythagoras/features/courses/domain/entities/course.dart';
import 'package:pythagoras/features/courses/domain/entities/course_badge_type.dart';

void main() {
  group('Course badgeType logic matrix', () {
    test('both not_requested should have badgeType none', () {
      final course = Course(
        id: '1',
        title: 'Test Course',
        price: 10,
        requestStatus: 'not_requested',
        chapterRequest: 'not_requested',
      );

      expect(course.badgeType, CourseBadgeType.none);
    });

    test(
      'request_status not_requested and chapter_request pending should be chapterPending',
      () {
        final course = Course(
          id: '1',
          title: 'Test Course',
          price: 10,
          requestStatus: 'not_requested',
          chapterRequest: 'pending',
        );

        expect(course.badgeType, CourseBadgeType.chapterPending);
      },
    );

    test(
      'request_status not_requested and chapter_request accepted should be chapterEnrolled',
      () {
        final course = Course(
          id: '1',
          title: 'Test Course',
          price: 10,
          requestStatus: 'not_requested',
          chapterRequest: 'accepted',
        );

        expect(course.badgeType, CourseBadgeType.chapterEnrolled);
      },
    );

    test(
      'request_status pending and chapter_request not_requested should be coursePending',
      () {
        final course = Course(
          id: '1',
          title: 'Test Course',
          price: 10,
          requestStatus: 'pending',
          chapterRequest: 'not_requested',
        );

        expect(course.badgeType, CourseBadgeType.coursePending);
      },
    );

    test(
      'request_status pending and chapter_request pending should be coursePending',
      () {
        final course = Course(
          id: '1',
          title: 'Test Course',
          price: 10,
          requestStatus: 'pending',
          chapterRequest: 'pending',
        );

        expect(course.badgeType, CourseBadgeType.coursePending);
      },
    );

    test(
      'request_status accepted should be courseEnrolled regardless of chapter_request',
      () {
        final course = Course(
          id: '1',
          title: 'Test Course',
          price: 10,
          requestStatus: 'accepted',
          chapterRequest: 'not_requested',
        );

        expect(course.badgeType, CourseBadgeType.courseEnrolled);
      },
    );

    test('isEnrolled true should be courseEnrolled', () {
      final course = Course(
        id: '1',
        title: 'Test Course',
        price: 10,
        isEnrolled: true,
        requestStatus: 'not_requested',
        chapterRequest: 'not_requested',
      );

      expect(course.badgeType, CourseBadgeType.courseEnrolled);
    });

    test(
      'CourseModel.fromJson parses request_status and chapter_request properly',
      () {
        final json = {
          'id': 21,
          'title': 'رياضيات الصف العاشر',
          'price': '35.00',
          'is_enrolled': false,
          'request_status': 'not_requested',
          'chapter_request': 'pending',
        };

        final model = CourseModel.fromJson(json);

        expect(model.requestStatus, 'not_requested');
        expect(model.chapterRequest, 'pending');
        expect(model.badgeType, CourseBadgeType.chapterPending);
      },
    );
  });
}

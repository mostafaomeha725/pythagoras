import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';
import 'package:pythagoras/features/courses/domain/entities/course_quiz.dart';
import 'package:pythagoras/features/courses/domain/entities/course_assignment.dart';
import 'package:pythagoras/features/courses/domain/entities/course_resource.dart';
import 'package:pythagoras/features/courses/domain/entities/course_chapter_statistics.dart';

class CourseChapter {
  final int id;
  final String title;
  final int order;
  final String price;
  final String currency;
  final String currencyLabel;
  final String requestStatus;
  final bool isEnrolled;
  final String? appleProductId;
  final List<CourseLesson> videos;
  final List<CourseQuiz> quizzes;
  final List<CourseAssignment> assignments;
  final List<CourseResource> resources;
  final CourseChapterStatistics? statistics;

  const CourseChapter({
    required this.id,
    required this.title,
    required this.order,
    required this.price,
    required this.currency,
    required this.currencyLabel,
    this.requestStatus = 'not_requested',
    this.isEnrolled = false,
    this.appleProductId,
    this.videos = const [],
    this.quizzes = const [],
    this.assignments = const [],
    this.resources = const [],
    this.statistics,
  });

  CourseChapter copyWith({
    int? id,
    String? title,
    int? order,
    String? price,
    String? currency,
    String? currencyLabel,
    String? requestStatus,
    bool? isEnrolled,
    String? appleProductId,
    List<CourseLesson>? videos,
    List<CourseQuiz>? quizzes,
    List<CourseAssignment>? assignments,
    List<CourseResource>? resources,
    CourseChapterStatistics? statistics,
  }) {
    return CourseChapter(
      id: id ?? this.id,
      title: title ?? this.title,
      order: order ?? this.order,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      currencyLabel: currencyLabel ?? this.currencyLabel,
      requestStatus: requestStatus ?? this.requestStatus,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      appleProductId: appleProductId ?? this.appleProductId,
      videos: videos ?? this.videos,
      quizzes: quizzes ?? this.quizzes,
      assignments: assignments ?? this.assignments,
      resources: resources ?? this.resources,
      statistics: statistics ?? this.statistics,
    );
  }
}

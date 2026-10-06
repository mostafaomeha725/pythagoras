import 'package:pythagoras/features/courses/domain/entities/course_chapter.dart';
import 'package:pythagoras/features/courses/data/models/course_lesson_model.dart';
import 'package:pythagoras/features/courses/data/models/course_quiz_model.dart';
import 'package:pythagoras/features/courses/data/models/course_assignment_model.dart';
import 'package:pythagoras/features/courses/data/models/course_resource_model.dart';
import 'package:pythagoras/features/courses/data/models/course_chapter_statistics_model.dart';

class CourseChapterModel extends CourseChapter {
  const CourseChapterModel({
    required super.id,
    required super.title,
    required super.order,
    required super.price,
    required super.currency,
    required super.currencyLabel,
    super.requestStatus,
    super.isEnrolled,
    super.videos,
    super.quizzes,
    super.assignments,
    super.resources,
    super.statistics,
  });

  factory CourseChapterModel.fromJson(Map<String, dynamic> json) {
    final videosData = json['videos'] as List<dynamic>? ?? [];
    final quizzesData = json['quizzes'] as List<dynamic>? ?? [];
    final assignmentsData = json['assignments'] as List<dynamic>? ?? [];
    final resourcesData = json['resources'] as List<dynamic>? ?? [];
    
    return CourseChapterModel(
      id: json['id'] as int,
      title: json['title'] as String,
      order: json['order'] as int? ?? 0,
      price: json['price'] as String? ?? '0',
      currency: json['currency'] as String? ?? '',
      currencyLabel: json['currency_label'] as String? ?? '',
      requestStatus: json['request_status'] as String? ?? 'not_requested',
      isEnrolled: json['is_enrolled'] as bool? ?? false,
      videos: videosData.map((v) => CourseLessonModel.fromJson(v)).toList(),
      quizzes: quizzesData.map((q) => CourseQuizModel.fromJson(q)).toList(),
      assignments: assignmentsData.map((a) => CourseAssignmentModel.fromJson(a)).toList(),
      resources: resourcesData.map((r) => CourseResourceModel.fromJson(r)).toList(),
      statistics: json['statistics'] != null
          ? CourseChapterStatisticsModel.fromJson(json['statistics'])
          : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/features/courses/domain/entities/course_detail.dart';
import 'package:pythagoras/features/courses/domain/entities/course_chapter.dart';
import 'package:pythagoras/features/courses/domain/entities/course_lesson.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_chapter_body.dart';
import 'package:pythagoras/features/courses/presentation/widgets/chapters/course_chapter_header.dart';

class CourseChapterTile extends StatefulWidget {
  final CourseChapter chapter;
  final int index;
  final bool isEnrolled;
  final bool showActionButtons;
  final bool showRestoreButton;
  final bool showLessonStatuses;
  final String? subtitle;
  final Color? backgroundColor;
  final Color? headerBackgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final CourseDetail? course;
  final String? selectedLessonId;
  final Function(CourseLesson)? onLessonTap;
  final bool tabletLandscape;

  const CourseChapterTile({
    super.key,
    required this.chapter,
    required this.index,
    required this.isEnrolled,
    this.showActionButtons = true,
    this.showRestoreButton = true,
    this.showLessonStatuses = false,
    this.subtitle,
    this.backgroundColor,
    this.headerBackgroundColor,
    this.border,
    this.boxShadow,
    this.course,
    this.selectedLessonId,
    this.onLessonTap,
    this.tabletLandscape = false,
  });

  @override
  State<CourseChapterTile> createState() => _CourseChapterTileState();
}

class _CourseChapterTileState extends State<CourseChapterTile> {
  bool _isExpanded = false;

  static const _bgColor = Color(0xFFF6EEF5);

  @override
  void initState() {
    super.initState();
    _checkInitialExpandedState();
  }

  void _checkInitialExpandedState() {
    if (widget.selectedLessonId != null) {
      final hasSelected = widget.chapter.videos.any(
        (v) => v.id == widget.selectedLessonId,
      );
      if (hasSelected) {
        _isExpanded = true;
      }
    }
  }

  @override
  void didUpdateWidget(covariant CourseChapterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedLessonId != oldWidget.selectedLessonId) {
      _checkInitialExpandedState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: widget.tabletLandscape ? 12 : 10.h),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? _bgColor,
        border: widget.border,
        boxShadow: widget.boxShadow,
        borderRadius: BorderRadius.circular(widget.tabletLandscape ? 16 : 16.r),
      ),
      child: Column(
        children: [
          // ── Header (always visible) ──────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: widget.headerBackgroundColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(widget.tabletLandscape ? 16 : 16.r),
                bottom: Radius.circular(
                  _isExpanded ? 0 : (widget.tabletLandscape ? 16 : 16.r),
                ),
              ),
            ),
            child: CourseChapterHeader(
              index: widget.index,
              title: widget.chapter.title,
              subtitle: widget.subtitle,
              isExpanded: _isExpanded,
              isCompleted:
                  widget.chapter.videos.isNotEmpty &&
                  widget.chapter.videos.every(
                    (v) => v.status == CourseLessonStatus.completed,
                  ),
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              tabletLandscape: widget.tabletLandscape,
            ),
          ),

          // ── Expandable body ───────────────────────────────────────
          if (_isExpanded)
            CourseChapterBody(
              chapter: widget.chapter,
              isEnrolled: widget.isEnrolled,
              showActionButtons: widget.showActionButtons,
              showRestoreButton: widget.showRestoreButton,
              showLessonStatuses: widget.showLessonStatuses,
              course: widget.course,
              selectedLessonId: widget.selectedLessonId,
              onLessonTap: widget.onLessonTap,
              tabletLandscape: widget.tabletLandscape,
            ),
        ],
      ),
    );
  }
}

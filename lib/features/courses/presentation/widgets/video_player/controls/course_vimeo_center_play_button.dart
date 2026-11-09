import 'package:flutter/material.dart';
import '../adapters/course_video_adapter.dart';
import 'course_video_center_control.dart';

class CourseVimeoCenterPlayButton extends StatelessWidget {
  final CourseVideoAdapter adapter;
  final bool showCustomControls;

  const CourseVimeoCenterPlayButton({
    super.key,
    required this.adapter,
    required this.showCustomControls,
  });

  @override
  Widget build(BuildContext context) {
    return CourseVideoCenterControl(
      adapter: adapter,
      visible: showCustomControls,
    );
  }
}

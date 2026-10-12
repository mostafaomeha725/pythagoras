import 'package:flutter/material.dart';

class CourseYoutubeTouchBlockers extends StatelessWidget {
  final VoidCallback onToggleControls;

  const CourseYoutubeTouchBlockers({super.key, required this.onToggleControls});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blocks clicks on YouTube title and avatar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggleControls,
          ),
        ),
        // Blocks clicks on YouTube logo and bottom elements
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggleControls,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class CourseVideoFullscreenBackButton extends StatelessWidget {
  final VoidCallback onToggleFullScreen;

  const CourseVideoFullscreenBackButton({
    super.key,
    required this.onToggleFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24.0,
      right: 24.0,
      child: SafeArea(
        child: GestureDetector(
          onTap: onToggleFullScreen,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24.0,
            ),
          ),
        ),
      ),
    );
  }
}

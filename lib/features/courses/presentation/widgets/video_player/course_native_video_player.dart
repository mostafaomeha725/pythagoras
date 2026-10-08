import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CourseNativeVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final Widget customControls;

  const CourseNativeVideoPlayer({
    super.key,
    required this.controller,
    required this.customControls,
  });

  @override
  State<CourseNativeVideoPlayer> createState() => _CourseNativeVideoPlayerState();
}

class _CourseNativeVideoPlayerState extends State<CourseNativeVideoPlayer> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio > 0 ? widget.controller.value.aspectRatio : 16 / 9,
            child: VideoPlayer(widget.controller),
          ),
        ),
        widget.customControls,
      ],
    );
  }
}

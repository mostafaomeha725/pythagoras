import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CourseYoutubePlayer extends StatelessWidget {
  final YoutubePlayerController controller;

  final Widget customControls;

  const CourseYoutubePlayer({
    super.key,
    required this.controller,
    required this.customControls,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        YoutubePlayer(
          controller: controller,
          autoFullScreen: false,
          controlsBuilder: (context, isFullscreen) {
            return customControls;
          },
        ),
      ],
    );
  }
}

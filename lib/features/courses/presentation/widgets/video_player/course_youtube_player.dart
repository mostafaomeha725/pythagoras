import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CourseYoutubePlayer extends StatelessWidget {
  final YoutubePlayerController controller;

  const CourseYoutubePlayer({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: controller,
      aspectRatio: 16 / 9,
      autoFullScreen: false, // Prevents fighting with our SystemChrome listener
    );
  }
}

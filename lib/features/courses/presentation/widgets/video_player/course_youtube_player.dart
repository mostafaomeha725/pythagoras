import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CourseYoutubePlayer extends StatelessWidget {
  final YoutubePlayerController controller;

  const CourseYoutubePlayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          YoutubePlayer(
            controller: controller,
            aspectRatio: 16 / 9,
            autoFullScreen:
                false, // Prevents fighting with our SystemChrome listener
          ),
          // Block touches on the top area (Video title and Share icon)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 70,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {}, // Absorb taps
              onDoubleTap: () {},
              onLongPress: () {},
              child: Container(color: Colors.transparent),
            ),
          ),
          // Block touches on a horizontal band JUST ABOVE the seek bar
          // This covers the "Copy Link" icon on the left AND the "Watch on YouTube" on the right
          // regardless of letterboxing, while leaving the bottom 35px (seek bar) clickable!
          Positioned(
            bottom:
                35, // Leave bottom 35px for the seek bar and fullscreen button
            left: 0,
            right: 0,
            height: 80, // Cover an 80px high band above the seek bar
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {}, // Absorb taps
              onDoubleTap: () {},
              onLongPress: () {},
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CourseNativeVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const CourseNativeVideoPlayer({super.key, required this.controller});

  @override
  State<CourseNativeVideoPlayer> createState() => _CourseNativeVideoPlayerState();
}

class _CourseNativeVideoPlayerState extends State<CourseNativeVideoPlayer> {
  bool _showControls = true;
  Timer? _hideControlsTimer;

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    
    _hideControlsTimer?.cancel();
    if (_showControls) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio > 0 
                ? widget.controller.value.aspectRatio 
                : 16 / 9,
            child: VideoPlayer(widget.controller),
          ),
          if (_showControls)
            Container(
              color: Colors.black45,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white, size: 40),
                      onPressed: () {
                        widget.controller.seekTo(
                          widget.controller.value.position - const Duration(seconds: 10),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: Icon(
                        widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 50,
                      ),
                      onPressed: () {
                        setState(() {
                          widget.controller.value.isPlaying
                              ? widget.controller.pause()
                              : widget.controller.play();
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.forward_10, color: Colors.white, size: 40),
                      onPressed: () {
                        widget.controller.seekTo(
                          widget.controller.value.position + const Duration(seconds: 10),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                widget.controller,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                colors: const VideoProgressColors(
                  playedColor: Colors.red,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
